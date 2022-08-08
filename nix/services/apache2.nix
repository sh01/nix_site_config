{writeText, lib, apacheHttpd}:
let
  pkg = apacheHttpd;
  concat = lib.concatStringsSep "\n";
in {
  fVhost = sname: els: concat ([''
    <VirtualHost *:80>
      ServerName ${sname}
      CustomLog /var/log/httpd/${sname}-access.log clog
      ErrorLog /var/log/httpd/${sname}-error.log
''] ++ els ++ ["\n</VirtualHost>\n"]);
  fUserdirs = ''
    UserDir public_html
    UserDir disabled root
    <Directory "/home/*/public_html">
      AllowOverride FileInfo AuthConfig Limit Indexes
      Options MultiViews Indexes SymLinksIfOwnerMatch IncludesNoExec
      <Limit GET POST OPTIONS>
        Require all granted
      </Limit>
      <LimitExcept GET POST OPTIONS>
        Require all denied
      </LimitExcept>
    </Directory>
'';
  fUserdirsCGIsh = ''
    <Directory "/home/sh/public_html">
		  Options +ExecCGI
    </Directory>
    AddHandler cgi-script .cgi .py
'';
  
  fAuth = {name, fn}: "\n" + ''
    <Location "/">
      AuthType Digest
      AuthName "${name}"
      AuthDigestDomain "${name}"
    
      AuthDigestProvider file
      AuthUserFile "${fn}"
      Require valid-user
	  </Location>
'';
  fForward = dst: "\n" + ''
    <Location "/">
      ProxyPass "${dst}"
    </Location>
'';
  
  modsDefault = [
    "mpm_event"
    "authn_core" "authn_file" "authz_core" "authz_user" "auth_digest"
    "log_config" "mime" "autoindex" "dir" "unixd" "cgid" "http2" "userdir" "include" "env"
    "proxy" "proxy_http" "proxy_wstunnel"
  ];
  confFile = mods: els: writeText "httpd.conf" (concat (
    (map (mn: "LoadModule ${mn}_module ${pkg}/modules/mod_${mn}.so") mods) ++ ["\n" ''
    ScriptSock /run/httpd/cgisock
    DefaultRuntimeDir /run/httpd/runtime
    PidFile /run/httpd/httpd.pid

    Listen *:80 http
    User wwwrun
    Group wwwrun

    LogFormat "%{%Y-%m-%d_%H:%M:%S}t.%{usec_frac}t %h %l %u \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\"" clog
    LogLevel notice
    CustomLog /var/log/httpd/_access.log clog
    ErrorLog /var/log/httpd/_error.log

    <Files ~ "^\.ht">
      Require all denied
    </Files>
    <Directory />
      Options FollowSymLinks
      AllowOverride None
      Require all denied
    </Directory>
''] ++ els));
}
