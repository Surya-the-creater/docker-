FROM httpd
LABEL description="This is httpd deployment"
COPY ecomm/ /usr/local/apache2/htdocs/
EXPOSE 80
CMD ["httpd-foreground"]

