postgresql:
  pkg:
    - name: postgresql-9.1
    - installed
  service:
    - running
    - enabled: True
    - watch:
      - file: /etc/postgresql/9.1/main/pg_hba.conf

pg_hba.conf:
  file.managed:
    - name: /etc/postgresql/9.1/main/pg_hba.conf
    - source: salt://postgres/pg_hba.conf
    - user: postgres
    - group: postgres
    - mode: 644
    - require:
      - pkg: postgresql-9.1


