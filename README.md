## Created with  `claude.ai`

# Pydio Cells Docker Deployment

This repository contains Docker configuration files for deploying Pydio Cells, an enterprise-grade file sharing and synchronization solution, along with MariaDB as the database backend.

## Table of Contents
- [Project Structure](#project-structure)
- [Configuration Files](#configuration-files)
- [Quick Start](#quick-start)
- [Detailed Configuration](#detailed-configuration)
- [Security Considerations](#security-considerations)
- [Volume Management](#volume-management)
- [Maintenance](#maintenance)
- [Troubleshooting](#troubleshooting)


## Project Structure

```plaintext
.
├── Dockerfile              # Multi-stage Dockerfile for Cells
├── docker-compose.yml      # Docker Compose configuration
├── install-conf.yml        # Cells installation configuration
├── docker-entrypoint.sh   # Container entrypoint script
└── README.md              # This documentation
```

## Configuration Files

### Dockerfile

The Dockerfile uses a multi-stage build process:
1. **Builder Stage**: Uses `golang:1.21-alpine` to compile Cells from source
2. **Runtime Stage**: Uses `busybox:glibc` for a minimal runtime environment

### docker-compose.yml

Defines two services:
- **cells**: The main Pydio Cells application
- **db**: MariaDB 10.6 database server

### install-conf.yml

Contains initial configuration for Cells including:
- Admin credentials
- Database connection details
- Collabora Online integration
- External URL configurations
- Server settings

## Quick Start

1. Clone this repository:
```bash
git clone <repository-url>
cd <repository-name>
```

2. Create a `.env` file (optional):
```bash
MYSQL_ROOT_PASSWORD=your_secure_password
MYSQL_PASSWORD=your_secure_password
FRONTEND_PASSWORD=your_secure_admin_password
```

3. Start the services:
```bash
docker compose up -d
```

4. Access the web interface:
```
http://localhost:8080
```

Default credentials:
- Username: admin
- Password: admin (change this immediately in production)

## Detailed Configuration

### Database Configuration

The MariaDB service is configured with:
- Version: 10.6
- Default database: cells
- Default user: cells
- Persistent storage using named volume

### Volume Management

Three Docker volumes are created:
- `dc-cells_working`: Cells working directory
- `dc-cells_data`: User data and files
- `dc-mysql_data`: Database files

### Network Configuration

- The Cells service exposes port 8080
- Internal communication between Cells and MariaDB uses Docker network
- Configure your reverse proxy to handle SSL termination

### Collabora Integration

Collabora Online is configured with:
- Host: collabora.convay.com
- Port: 9980
- SSL: disabled (handled by reverse proxy)
- WOPI integration enabled

**Important Note:** After configuring Collabora from the web UI:
1. Save the Collabora configuration in the UI
2. Restart the Cells server using:
   ```bash
   docker compose restart cells
   ```
This restart is necessary for the Collabora integration to work properly. The changes made in the UI need a server restart to take full effect.

## Security Considerations

1. **Password Management**:
   - Change default passwords immediately
   - Use environment variables for sensitive data
   - Consider using Docker secrets in swarm mode

2. **Network Security**:
   - Use reverse proxy with SSL termination
   - Enable TLS for database connections in production
   - Implement proper firewall rules

3. **File Permissions**:
   - Volumes are created with appropriate permissions
   - Sensitive configuration files are mounted read-only

## Maintenance

### Backup Procedure

1. Database backup:
```bash
docker compose exec db mysqldump -u root -p cells > backup.sql
```

2. Volume backup:
```bash
docker run --rm -v dc-cells_data:/data -v $(pwd):/backup alpine tar czf /backup/cells_data.tar.gz /data
```

### Updates

1. Pull new images:
```bash
docker compose pull
```

2. Rebuild Cells service:
```bash
docker compose build --no-cache cells
```

3. Apply updates:
```bash
docker compose up -d
```

## Troubleshooting

### Common Issues

1. **Database Connection Errors**:
   - Verify database credentials in install-conf.yml
   - Check if MariaDB service is running
   - Ensure network connectivity between containers

2. **Permission Issues**:
   - Check volume permissions
   - Verify user/group mappings
   - Review container logs for access errors

3. **Memory Issues**:
   - Ensure sufficient RAM allocation
   - Monitor container resource usage
   - Check for memory leaks

### Logging

View service logs:
```bash
# All services
docker compose logs

# Specific service
docker compose logs cells
docker compose logs db
```

### Health Checks

Monitor service health:
```bash
docker compose ps
docker compose top
```

## Support and Resources

- [Pydio Cells Documentation](https://pydio.com/en/docs/cells)
- [Docker Documentation](https://docs.docker.com/)
- [MariaDB Documentation](https://mariadb.com/kb/en/documentation/)

## License

This Docker configuration is provided under the same license as Pydio Cells. Refer to the official Pydio documentation for licensing details.