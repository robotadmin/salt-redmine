redmine:
  group:
    - present
  user.present:
    - home: /home/redmine
    - shell: /bin/bash
    - groups:
      - redmine
      - rvm
      - sudo
    - require:
      - group: redmine
      - group: rvm

ruby-1.9.3:
  rvm.installed:
    - default: True
    - runas: redmine
    - require:
      - pkg: rvm-deps
      - pkg: mri-deps
      - user: redmine

ruby-2.0.0:
  rvm.installed:
    - default: True
    - runas: redmine
    - require:
      - pkg: rvm-deps
      - pkg: mri-deps
      - user: redmine

redmine_rails3.2.13:
  rvm.gemset_present:
    - ruby: 2.0.0
    - runas: redmine
    - require:
      - rvm: ruby-2.0.0

install rails:
  cmd.run:
    - name: /home/redmine/.rvm/bin/rvm 2.0.0@redmine_rails3.2.13 do gem install rails --version 3.2.13
    - user: redmine
    - shell: /bin/bash

