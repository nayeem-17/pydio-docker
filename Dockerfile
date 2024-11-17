# Build stage
FROM golang:1.21-alpine AS builder

# Install build dependencies
RUN apk add --no-cache git make build-base jq

# Set working directory
WORKDIR /go/src/github.com/pydio/cells

# Clone the repository (alternatively, you could COPY local source)
RUN git clone https://github.com/pydio/cells .

# Build frontend assets
RUN make frontend

# Build the application in production mode
RUN make clean && make main

# Runtime stage
FROM busybox:glibc
ARG version

# Copy necessary files from builder
COPY --from=builder /go/src/github.com/pydio/cells/cells /opt/pydio/bin/cells
COPY --from=builder /usr/bin/jq /bin/jq
COPY docker-entrypoint.sh /opt/pydio/bin/docker-entrypoint.sh
COPY libdl.so.2 /opt/pydio/bin/libdl.so.2

# Install certificates
COPY --from=builder /etc/ssl/certs /etc/ssl/certs

# Set environment variables
ENV CADDYPATH=/var/cells/certs 
ENV CELLS_WORKING_DIR=/var/cells
WORKDIR $CELLS_WORKING_DIR

# Final configuration
RUN ln -s /opt/pydio/bin/cells /bin/cells \
    && ln -s /opt/pydio/bin/libdl.so.2 /lib64/libdl.so.2 \
    && ln -s /opt/pydio/bin/docker-entrypoint.sh /bin/docker-entrypoint.sh \
    && chmod +x /opt/pydio/bin/docker-entrypoint.sh \
    && echo "Pydio Cells Home Docker Image" > /opt/pydio/package.info \
    && echo "  A ready-to-go Docker image based on BusyBox to configure and launch Cells in no time." >> /opt/pydio/package.info \
    && echo "  Generated on $(date) with docker build script from version ${version}" >> /opt/pydio/package.info

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["cells", "start"] 