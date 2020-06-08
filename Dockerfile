# build stage
FROM node:12-stretch as build

RUN mkdir /tmp/build

WORKDIR /tmp/build

COPY package.json package-lock.json ./

RUN npm ci

COPY . .

# run stage
FROM alpine:3.10

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories

RUN apk update
RUN apk add --no-cache nodejs

RUN addgroup -S node && adduser -S node -G node

USER node

RUN mkdir /home/node/app

WORKDIR /home/node/app

# copy from build stage
COPY --from=build --chown=node:node /tmp/build .

CMD ["node", "index.js"]
