FROM node:alpine
WORKDIR /node-todo
COPY . .
RUN npm install

# CONFIG STANDARD ERROR LOG
RUN ln -sf /dev/stdout /var/log/access.log \
	&& ln -sf /dev/stderr /var/log/error.log

RUN apk add mongodb
EXPOSE 8080


ENTRYPOINT ["node", "server.js"]
