FROM repo/wincore-oe:0.1

WORKDIR /app/
COPY build/assemblies/ assemblies/
COPY build/static/ ./
COPY build/ablcontainer/pl/ ablcontainer/
COPY build/oe11/pl/ application/

CMD ["start.bat"]
