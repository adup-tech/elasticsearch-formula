include:
  - elasticsearch.pkg

{% from "elasticsearch/settings.sls" import elasticsearch with context %}
{%- set plugins_pillar = salt['pillar.get']('elasticsearch:plugins', {}) %}

{% if elasticsearch.major_version == 5 %}
  {%- set plugin_bin = 'elasticsearch-plugin' %}
{% else %}
  {%- set plugin_bin = 'plugin' %}
{% endif %}

{% for name, repo in plugins_pillar.items() %}
elasticsearch-remove-{{ name }}:
  cmd.run:
    - name: /usr/share/elasticsearch/bin/{{ plugin_bin }} remove {{ name }}
    - onchanges:
      - elasticsearch_pkg
    - unless: test ! -x /usr/share/elasticsearch/plugins/{{ name }}
{% endfor %}

{% for name, repo in plugins_pillar.items() %}
elasticsearch-{{ name }}:
  cmd.run:
    - name: /usr/share/elasticsearch/bin/{{ plugin_bin }} install -b {{ repo }}
    - require:
      - sls: elasticsearch.pkg
    - unless: test -x /usr/share/elasticsearch/plugins/{{ name }}
{% endfor %}
