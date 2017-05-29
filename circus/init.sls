{% from "circus/map.jinja" import circus with context %}

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
