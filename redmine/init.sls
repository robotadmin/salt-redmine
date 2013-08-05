{% set user = pillar['ruby_config']['gemset_user'] %}

http://svn.redmine.org/redmine/branches/2.3-stable:
  svn.latest:
    - target: /home/{{user}}/redmine2.3

change-permissions:
  cmd.run:
    - name: chown {{user}} /home/{{user}}/redmine2.3

cd-redmine:
  cmd.wait:
    - name: cd /home/{{user}}/redmine2.3
    - user: {{user}}
    - watch:
      - change-permissions

  


