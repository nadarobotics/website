FROM docker.io/klakegg/hugo:ext-alpine AS hugo-builder

COPY . /src
RUN hugo

FROM docker.io/library/nginx:alpine

COPY --from=hugo-builder /src/public /usr/share/nginx/html
COPY ./nginx/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
