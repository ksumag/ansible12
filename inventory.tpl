---
  all:
     vars:
        ansible_user: root
        ansible_ssh_private_key_file: ${access_key}
     children:
          loadbalancer_servers: 
           hosts:
%{for index, k in LB_servers ~}
              ${name_lb[index]}:
                ansible_host: ${ip_lb[index]}
%{endfor ~}  
          app_servers: 
           hosts:
%{for index, k in APP_servers ~}
              ${name_app[index]}:
                ansible_host: ${ip_app[index]}      
%{endfor ~}        
              