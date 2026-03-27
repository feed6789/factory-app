# Giai đoạn 1: Build App (Dùng Flutter SDK)
FROM ghcr.io/cirruslabs/flutter:stable AS build-env
WORKDIR /app
COPY . .
RUN flutter pub get
RUN flutter build web

# Giai đoạn 2: Đóng gói để chạy (Dùng Nginx siêu nhẹ)
FROM nginx:alpine
COPY --from=build-env /app/build/web /usr/share/nginx/html
EXPOSE 80