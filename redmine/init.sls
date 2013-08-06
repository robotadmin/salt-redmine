include:
  - postgres

{% set user = pillar['ruby_config']['gemset_user'] %}
{% set redmine_dir = pillar['redmine_config']['installation_dir'] %}
{% set redmine_language = pillar['redmine_config']['language'] %}
{% set rvm_do = "/home/%s/.rvm/bin/rvm ruby-2.0.0@redmine_ruby-2.0.0_rails-3.2.13 do"%user %}

get-redmine:
  svn.latest:
    - name: http://svn.redmine.org/redmine/branches/2.3-stable
    - target: {{redmine_dir}}
    - require: 
      - pkg: postgresql

change permissions:
  cmd.run:
    - names: 
      - chown -R {{user}}:{{user}} {{redmine_dir}}
      - mkdir -p tmp tmp/pdf public/plugin_assets
      - chown -R {{user}}:{{user}} files log tmp public/plugin_assets
      - chmod -R 755 files log tmp public/plugin_assets
    - cwd: {{redmine_dir}}
    - require:
      - svn: get-redmine

redminepguser:
  postgres_user.present:
    - name: 'redmine'
    - password: 'redmine'
    - runas: postgres
    - require:
      - service: postgresql

redminepgdb:
  postgres_database.present:
    - name: 'redmine'
    - encoding: UTF8
    - lc_ctype: en_US.UTF8
    - lc_collate: en_US.UTF8
    - template: template0
    - owner: 'redmine'
    - runas: postgres
    - require:
      - service: postgresql
      - postgres_user: redminepguser

database.yml:
  file.managed:
    - name: {{redmine_dir}}/config/database.yml
    - source: salt://redmine/database.yml
    - user: redmine
    - mode: 644
    - require:
      - postgres_user: redminepguser
      - postgres_database: redminepgdb

Gemfile.local:
  file.managed:
    - name: {{redmine_dir}}/config/Gemfile.local
    - source: salt://redmine/Gemfile.local
    - user: redmine
    - mode: 644

redmine-deps:
  pkg.installed:
    - names: 
      - imagemagick
      - libmagickwand-dev
      - libpq-dev

bundler:
  gem.installed:
    - runas: redmine
    - ruby: 2.0.0@redmine_ruby-2.0.0_rails-3.2.13
    - require:
      - svn: get-redmine

bundle-install:
  cmd.run:
    - name: {{rvm_do}} bundle install --without development test
    - cwd: {{redmine_dir}}
    - user: {{user}}
    - shell: /bin/bash
    - require:
      - svn: get-redmine
      - gem: bundler
      - pkg: redmine-deps
      - file: database.yml
      - file: Gemfile.local

session-secret-generation:
  cmd.run:
    - name: {{rvm_do}} rake generate_secret_token
    - cwd: {{redmine_dir}}
    - user: {{user}}
    - shell: /bin/bash
    - require:
      - cmd: bundle-install

database-schema:
  cmd.run:
    - name: RAILS_ENV=production {{rvm_do}} rake db:migrate
    - cwd: {{redmine_dir}}
    - user: {{user}}
    - shell: /bin/bash
    - require:
      - cmd: bundle-install
      - cmd: session-secret-generation

db-default-data-set:
  cmd.run:
    - name: RAILS_ENV=production REDMINE_LANG={{redmine_language}} {{rvm_do}} rake redmine:load_default_data
    - cwd: {{redmine_dir}}
    - user: {{user}}
    - shell: /bin/bash
    - require:
      - cmd: bundle-install
      - cmd: session-secret-generation
