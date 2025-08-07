# Java Web Application Deployment on GCP

This project deploys a Java-based web application (running on Tomcat) with a full production-ready stack on Google Cloud Platform (GCP). It includes MySQL (MariaDB), Memcached, RabbitMQ, HTTPS via an SSL certificate, and integrates with a domain from GoDaddy.

---

## 💻 Stack Overview

- **Application Server**: Apache Tomcat (runs a Java app built with Maven)
- **Database**: MariaDB (MySQL-compatible)
- **Cache**: Memcached
- **Queue**: RabbitMQ
- **Domain**: `dark-lord.xyz` (from GoDaddy)
- **OS**: CentOS Stream 9
- **JDK**: OpenJDK 17

---

## ☁️ Cloud Architecture

- **GCP Compute Engine**
  - Hosts Tomcat, MariaDB, Memcached, and RabbitMQ
- **Managed Instance Group**
  - Auto-scales the backend Tomcat servers
- **HTTP(S) Load Balancer (ALB)**
  - Distributes traffic to backend instances
  - Handles both HTTP and HTTPS traffic
  - SSL certificate managed by Google
- **Cloud DNS**
  - Domain `dark-lord.xyz` pointed to the ALB via A/AAAA records

---

## ⚙️ Deployment Process

1. **Startup Script**
   - Installs required tools (OpenJDK, Maven, MariaDB, Memcached, RabbitMQ, Tomcat)
   - Builds the Java application using `mvn package`
   - Copies and edits the `application.properties` before build
   - Deploys the `.war` file to Tomcat

2. **Google Cloud Storage (GCS)**
   - Used to store and retrieve the app source code and configurations

3. **Load Balancer Script**
   - Creates backend service
   - Health check for Tomcat (port 8080)
   - Frontend with both HTTP and HTTPS support
   - SSL Certificate is provisioned and domain verified via GoDaddy

4. **Auto-scaling Script**
   - Creates instance template with the startup script
   - Creates a managed instance group
   - Auto-scaling policies based on CPU utilization
   - Connects to backend service of the load balancer

---

## 🧱 Infrastructure Components

- **Instance Template**: Configures VMs for Tomcat with metadata and startup script
- **Managed Instance Group**: Automatically adds/removes instances based on load
- **Target Pool**: Receives traffic from the load balancer
- **Health Check**: Monitors `/` endpoint on port 8080
- **Firewall Rules**: Allow HTTP (80), HTTPS (443), SSH (22), MySQL (3306), Memcached (11211), and RabbitMQ (5672)

---

## 🧠 Issues Faced & Solutions

| Issue | Solution |
|------|----------|
| Startup script logs hard to find | Checked `/var/log/syslog` and `journalctl -u google-startup-scripts.service` |
| ALB not working with HTTP/HTTPS | Verified forwarding rules and certificate provisioning |
| Can't SSH or stuck in terminal | Press `Ctrl + D` or run a new SSH session |
| Application.properties changes | Manually edited before Maven build, then rebuilt and uploaded to GCS |
| GCP firewall not opening ports | Used tags and specified rules clearly |
| Domain not pointing correctly | Updated DNS records in GoDaddy to point to ALB IPs (A/AAAA) |

---

## 🔗 Domain Setup

- Domain: `dark-lord.xyz`
- Domain Provider: GoDaddy
- Steps:
  - Created A record pointing to ALB IPv4
  - Created AAAA record pointing to ALB IPv6
  - Verified domain ownership using SSL certificate provisioning (automated)

---

## 📦 Build & Deploy

```bash
# Edit application.properties locally
# Rebuild the project
mvn clean package

# Upload new files to GCS
gsutil cp app.war gs://your-bucket-name/
gsutil cp application.properties gs://your-bucket-name/

# Re-run autoscale script to redeploy
./create-autoscale.sh

