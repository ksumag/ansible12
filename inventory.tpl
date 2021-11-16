---
   stage_1:
          hosts:
           ${name}:
              ansible_host: ${ip}
              ansible_user: root
              ansible_ssh_private_key_file: ${access_key}