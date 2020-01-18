FROM ubuntu
RUN apt update -y  && apt --no-install-recommends install  python-pip -y &&  apt --no-install-recommends  install python3-pip -y
RUN pip install -U setuptools 
RUN pip install pip==9.0.0 
RUN pip install ansible 
RUN pip install kolla-ansible  
RUN pip install docker
RUN apt  install nodejs -y && apt install docker.io -y && apt-get install npm -y && node -v  && npm -v 
RUN apt clean all 
RUN apt autoremove -y
RUN mkdir /data/ -p 
COPY  ./src /data/src 
WORKDIR /data/src/
RUN npm i -g request && npm i -g fs && npm i -g path && npm i -g shelljs && npm i -g js-yaml
RUN cd  /data/src/
RUN mkdir /etc/kolla/ -p && cp ./passwords.yml  /etc/kolla/ 
COPY ./globals.yml /etc/kolla/
RUN ls  /etc/kolla/
CMD [ "systemctl enable docker.service" , "systemctl start docker.service"]
ENTRYPOINT [ "node", "app.js"  ]
