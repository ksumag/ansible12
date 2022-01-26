---
  all:
     vars:
        ansible_user: root
        ansible_ssh_private_key_file: ${access_key}
     children:
          loadbalancer_servers: 
           hosts:
%{for index, k in VPStype ~}
%{if index < 1 ~}  
              ${name[index]}_${index+1}:
                ansible_host: ${ip[index]}
          app_servers: 
           hosts:
%{else ~}
              ${name[index]}_${index}:
                ansible_host: ${ip[index]}      
%{endif ~}
%{endfor ~}        
              