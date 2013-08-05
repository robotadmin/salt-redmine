include:
  - rvm

{% set user = pillar['ruby_config']['gemset_user'] %}
{% set rubies = pillar['ruby_config']['rubies'] %}

{{user}}:
  group:
    - present
  user.present:
    - home: /home/{{user}}
    - shell: /bin/bash
    - groups:
      - {{user}}
      - rvm
    - require:
      - group: {{user}}
      - group: rvm

{% for ruby in rubies %}
{{ ruby }}:
  rvm.installed:
    - default: True
    - runas: {{user}}
    - require:
      - pkg: rvm-deps
      - pkg: mri-deps
      - user: {{user}}
{% endfor %}
