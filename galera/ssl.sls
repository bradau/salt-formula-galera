{%- from "galera/map.jinja" import master, slave with context %}

{%- set service = master if pillar.galera.master is defined else slave %}
{%- set role = 'master' if pillar.galera.master is defined else 'slave' %}

{%- if service.get('ssl', {}).get('enabled', False) %}
{%- if service.ssl.cacert_chain is defined %}
mysql_cacertificate:
  file.managed:
    - name: {{ service.ssl.ca_file }}
    - contents_pillar: galera:{{ role }}:ssl:cacert_chain
    - mode: 0444
    - makedirs: true
    - require_in:
      - service: galera_service
{%- else %}
mysql_cacertificate_exists:
  file.exists:
  - name: {{ service.ssl.ca_file }}
mysql_cacertificate:
  file.managed:
  - name: {{ service.ssl.ca_file }}
  - mode: 644
  - create: False
  - require:
    - file: mysql_cacertificate_exists
  - require_in:
    - service: galera_service
{%- endif %}

{%- if service.ssl.cert is defined %}
mysql_certificate:
  file.managed:
    - name: {{ service.ssl.cert_file }}
    - contents_pillar: galera:{{ role }}:ssl:cert
    - mode: 0444
    - makedirs: true
    - require_in:
      - service: galera_service
{%- else %}
mysql_certificate_exists:
  file.exists:
  - name: {{ service.ssl.cert_file }}
mysql_certificate:
  file.managed:
    - name: {{ service.ssl.cert_file }}
    - mode: 644
    - create: False
    - require:
      - file: mysql_certificate_exists
    - require_in:
      - service: galera_service
{%- endif %}

{%- if service.ssl.key is defined %}
mysql_server_key:
  file.managed:
    - name: {{ service.ssl.key_file }}
    - contents_pillar: galera:{{ role }}:ssl:key
    - user: root
    - group: mysql
    - mode: 0440
    - makedirs: true
    - require_in:
      - service: galera_service
{%- else %}
mysql_server_key_exists:
  file.exists:
    - name: {{ service.ssl.key_file }}
mysql_server_key:
  file.managed:
    - name: {{ service.ssl.key_file }}
    - user: root
    - group: mysql
    - mode: 0440
    - create: False
    - require:
      - file: mysql_server_key_exists
    - require_in:
       - service: galera_service
{%- endif %}

{%- endif %}
