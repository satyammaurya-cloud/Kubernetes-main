# Probes in Kubernetes

Bhai, tension mat le, probes thoda confusing ho sakte hain kyunki ye "doctor" ki tarah kaam karte hain jo check karte hain ki aapka pod healthy hai ya nahi.

## Samjho Asan Bhasha Mein
Kubernetes ko kaise pata chalega ki aapka container sahi se chal raha hai? Use probe chahiye.

## Teen Tarah ke Probes

**Startup Probe:**
- "School Admission" jaisa.
- Ye sirf ek baar chalta hai (jab tak success na mil jaye).
- Ek baar pass ho gaya, toh ye mar jata hai (stop ho jata hai).

**Readiness Probe:**
- "Traffic Signal" jaisa.
- Jab tak container zinda hai, ye hamesha chalta rehta hai (traffic rokne/bhejne ke liye).

**Liveness Probe:**
- "Bodyguard" jaisa.
- Jab tak container zinda hai, ye hamesha chalta rehta hai (restart karne ke liye).

---

### 1. Liveness Probe (Zinda hai ya mar gaya?)
- **Kaam:** Ye check karta hai ki container chal raha hai ya "hang" ho gaya hai.
- **Result:** Agar ye probe fail hua, toh Kubernetes container ko kill karke restart kar dega.
- **Real life example:** Ek banda so raha hai ya behosh hai? Agar behosh hai toh use thappad maarke (restart) uthao.

### 2. Readiness Probe (Kaam karne ke liye taiyar hai?)
- **Kaam:** Ye check karta hai ki kya container traffic (users) handle karne ke liye ready hai? Ho sakta hai container start ho gaya ho, par database se connect hone mein time lag raha ho.
- **Result:** Agar ye fail hua, toh Kubernetes is pod par traffic bhejna band kar dega, par ise kill nahi karega.
- **Real life example:** Dukaan khul gayi hai (Liveness OK), par dukandaar abhi saman set kar raha hai. Jab tak saman set nahi hota, customers ko andar mat aane do.

### 3. Startup Probe (Abhi paida ho raha hai?)
- **Kaam:** Ye sirf shuruat mein chalta hai un containers ke liye jo start hone mein bahut zyada time lete hain (heavy apps).
- **Result:** Jab tak Startup probe success nahi hota, baaki dono probes (Liveness/Readiness) wait karte hain.
- **Real life example:** Chhota baccha jab tak chalna nahi seekh leta, hum use race mein nahi daalte.

## YAML Mein Kaise Dikhta Hai?

```yaml
livenessProbe:
  httpGet:            # Ek URL check karo
    path: /healthz    # Is path par request bhejega
    port: 8080
  initialDelaySeconds: 3  # Container start hone ke 3 sec baad check shuru karo
  periodSeconds: 5        # Har 5 sec mein check karo
```

## Simple Trick Yaad Rakhne Ki:
- **Liveness = Restart** *(Health check)*
- **Readiness = Traffic** *(Are you ready?)*
- **Startup = Slow starter** *(Don't disturb me yet)*

-------------------
# Kubernetes Probes: Simple Notes

## What is a Probe?
A Probe is a "health check" performed by Kubernetes on your container to see if it is working correctly.

### Types of Probes:
1. **Liveness Probe** ("Am I alive?")
   - **Purpose:** Checks if the container is running or crashed/stuck.
   - **Action:** If it fails, Kubernetes restarts the container.
   - **Use case:** Use this to fix apps that hang or freeze.

2. **Readiness Probe** ("Am I ready for work?")
   - **Purpose:** Checks if the app is ready to handle user traffic (e.g., is the database connected?).
   - **Action:** If it fails, Kubernetes stops sending traffic to this pod, but does not restart it.
   - **Use case:** Use this during app startup so users don't see "404 Not Found" errors.

3. **Startup Probe** ("Am I still waking up?")
   - **Purpose:** For heavy apps that take a long time to start.
   - **Action:** It disables Liveness and Readiness checks until the app is fully started.
   - **Use case:** Use this if your app takes 1-2 minutes to boot up.

## How Kubernetes checks (Methods)
There are 3 ways Kubernetes "pokes" your container:
- `httpGet`: It hits a URL (like `/health`). If it gets a `200 OK`, it passes.
- `exec`: It runs a command (like `cat /tmp/healthy`) inside the container. If it returns `0`, it passes.
- `tcpSocket`: It checks if a specific port (like `8080`) is open.
---
## Simple YAML Template

Here is a simple YAML example for each probe.

## 1. Liveness Probe (The "Restart" Check)
This restarts the container if the `/healthz` path returns an error.

```yaml
livenessProbe:
  httpGet:
    path: /healthz
    port: 8080
  initialDelaySeconds: 3   # Wait 3s after start to check
  periodSeconds: 3         # Check every 3s
  failureThreshold: 3      # Restart after 3 failed attempts
```


## 2. Readiness Probe (The "Traffic" Check)
This stops sending users to the Pod if the app is still loading or busy.

```yaml
readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5   # Wait 5s before checking
  periodSeconds: 5         # Check every 5s
  successThreshold: 1      # Needs 1 success to be "Ready"
```


## 3. Startup Probe (The "Slow Loader" Check)
This is for apps that take a long time to start. It protects the app from being killed by the Liveness probe before it finishes booting.

```yaml
startupProbe:
  httpGet:
    path: /healthz
    port: 8080
  failureThreshold: 30     # Try 30 times
  periodSeconds:10        # Every10s (gives app300s total to start)
```


## All Together in one Pod:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: probe-demo
spec:
  containers:
  - name: my-app
    image: nginx
    # Startup Probe runs FIRST
    startupProbe:
      httpGet:
        path: /
        port: 80
      failureThreshold: 30
      periodSeconds: 10
    # Liveness and Readiness start ONLY after Startup succeeds
    livenessProbe:
      httpGet:
        path: /
        port: 80
    readinessProbe:
      httpGet:
        path: /
        port: 80

```
Key Tip: In a real app, startupProbe runs first. Once it passes, it stops, and then liveness and readiness take over for the rest of the Pod's life.
