#!@interp@

for d in \
    "$(echo sh_cbrowser) browsers un"\
    "$(echo sh_prsw) prsw"\
    "$(echo sh_prsw_net) prsw_net";
{
  read D un tlvl <<<"$d"
  fn="/home/${un}/$(whoami)/.Xauthority"
  hn=$(echo "${un}" | sed 's:_:-:g')

  umask 077
  T=$(mktemp)
  "@xauth@" -f "$T" generate "${DISPLAY}" . "${tlvl}trusted" group "$hn" timeout 0
  umask 026
  ## We need to patch the Xauthority hostname for it to work right from inside containers.
  cat $T | "@fPatchXauth@" "${hn}" | ssh "${un}@${hn}" "rm -f ${fn}; umask 026; cat > ${fn}"
  rm -f $T
  ssh "${un}@${hn}" "chgrp sh_x ${fn}; chmod g+r ${fn}"
}
