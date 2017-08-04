include:
  - elasticsearch.pkg
  - elasticsearch.config

{% from "elasticsearch/settings.sls" import elasticsearch with context %}
{%- set plugins_pillar = salt['pillar.get']('elasticsearch:plugins', {}) %}

elasticsearch_service:
  service.running:
    - name: elasticsearch
    - enable: True
{%- if salt['pillar.get']('elasticsearch:config') or plugins_pillar %}
    - watch:
      {%- if salt['pillar.get']('elasticsearch:config') %}
      - file: elasticsearch_cfg
      {%- endif
      {% for name in plugins_pillar.keys() %}
      - elasticsearch-{{ name }}
      {% endfor %}
{%- endif %}
    - require:
      - pkg: elasticsearch
