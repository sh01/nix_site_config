name: ugid: {
  users.users."${name}" = {
    uid = ugid;
    group = "${name}";
    isSystemUser = true;
    createHome = true;
    home = "/home/${name}";
  };
  users.groups."${name}" = {
    gid = ugid;
  };
}
