include:
  - postgres

{% set user = pillar['ruby_config']['gemset_user'] %}

get-redmine:
  svn.latest:
    - name: http://svn.redmine.org/redmine/branches/2.3-stable
    - target: /home/{{user}}/redmine2.3
    - require: 
      - pkg: postgresql

change permissions:
  cmd.run:
    - name: chown {{user}} /home/{{user}}/redmine2.3

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
      - postgres_user: redminepguser

database.yml:
  file.managed:
    - name: /home/redmine/redmine2.3/database.yml
    - source: salt://redmine/database.yml
    - user: redmine
    - mode: 644
    - require:
      - postgres_database: redminepgdb

bundler:
  gem.installed:
    - runas: redmine
    - ruby: 2.0.0@redmine_ruby-2.0.0_rails-3.2.13
    - require:
      - svn: get-redmine

bundle-install:
  cmd.run:
    - name: /home/{{user}}/.rvm/bin/rvm ruby-2.0.0@redmine_ruby-2.0.0_rails-3.2.13 do bundle install --without development test
    - user: {{user}}
    - shell: /bin/bash
    - require:
      - gem: bundler