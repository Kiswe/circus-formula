{% from "circus/map.jinja" import circus with context %}
{% set use_upstart = salt['pillar.get']('circus:use_upstart', True) %}

include:
  - circus.conf
  - circus.plugin
  - circus.socket
  - circus.watcher

circus-dependencies:
  pkg.installed:
    - pkgs:
      - libevent-dev
      - python-dev

circus-init-script:
  file.managed:
    - name: /etc/init.d/circus
    - source: salt://circus/templates/init.sh.tmpl
    - template: jinja
    - mode: 0755
  {% if use_upstart %}
  file.managed:
    - name: /etc/init/circus.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 440
    - source: salt://circus/templates/upstart.jinja
    - require:
      - pip: circus
  {% endif %}

circus:
  pip.installed:
    - pkgs:
      - pyzmq 
      - circus
    - require:
      - pkg: circus-dependencies
  service:
    - running
    - enable: True
    - watch:
      - file: {{ circus.conf_dir }}/circus.ini
    - require:
      - file: {{ circus.conf_dir }}/circus.ini
      - file: circus-init-script
      - pip: circus

