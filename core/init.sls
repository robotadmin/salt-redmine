git-core:
  pkg:
    - installed 
#pkg.installed:
#  {% if grains['os'] == 'Ubuntu' %}
#  - name: git-core
#  {% else -%}
#  - name: git
#  {% endif -%}  
svn:
  pkg:
    - installed
curl:
  pkg:
    - installed
wget:
  pkg:
    - installed
