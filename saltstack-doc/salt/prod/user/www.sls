www-user-group:
  group.present:
    - name: www
    - gid: 1500
  user.present:
    - name: www
    - fullname: www
    - shell: /sbin/nologin
    - uid: 1500
    - gid: 1500
