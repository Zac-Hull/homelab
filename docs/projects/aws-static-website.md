# ZacHull.com Static Cloud Migration

## Overview

This project documents the migration of `zachull.com` from a Lightsail-hosted WordPress site to a static Astro portfolio hosted on AWS using S3, CloudFront, Route 53, ACM, and CloudFront Functions.

The goal was not only to replace the old website, but to turn the website itself into a practical cloud engineering project. The final architecture needed to be low-cost, easier to maintain, version-controlled, secure by default, and capable of supporting future automation through GitHub Actions and infrastructure as code.

The project started as a local Astro site on my MacBook and progressed into a production static site served through CloudFront with a private S3 origin.

---

## Current Production Architecture
```text
Visitor
  ↓
Route 53
  ↓
CloudFront
  ↓
CloudFront Function URL rewrite
  ↓
Private S3 origin bucket
  ↓
Astro static site files
```

The site currently uses:

- **Astro** for static site generation
- **GitHub** for source control
- **Amazon S3** for static asset storage
- **CloudFront** for global edge delivery
- **CloudFront Origin Access Control** for private S3 access
- **CloudFront Functions** for clean URL routing
- **AWS Certificate Manager** for TLS
- **Route 53** for DNS
- **GitHub Actions** for automated production deployment
- **AWS OpenID Connect** for short-lived deployment authentication
- **AWS CLI** as a manual fallback and local administrative tool

---

## Problem This Project Solved

The original site was a Lightsail-hosted WordPress deployment. It worked, but it was heavier than necessary for a mostly static professional portfolio.

The old approach created several problems:

- WordPress required ongoing plugin, theme, and application maintenance.
- The site had stale content that was harder to update and version cleanly.
- The WordPress comment system created unnecessary attack surface.
- Content edits were not handled through a Git-based workflow.
- The hosting model did not clearly reflect the cloud engineering skills I wanted the site to represent.
- The site was more expensive and operationally noisy than a static portfolio needed to be.

The new architecture solves those problems by removing the CMS layer, reducing the amount of infrastructure that needs patching, and making the website deployment itself part of the portfolio.

---

## Goals
### Short-Term Goals
- Replace the Lightsail WordPress site with a static Astro portfolio.
- Host the site through a private S3 bucket behind CloudFront.
- Use Route 53 and ACM for a proper custom domain and HTTPS.
- Keep the AWS footprint low-cost.
- Preserve the old Lightsail site temporarily as rollback during cutover.
- Document the process clearly enough to explain the decisions later.
### Long-Term Goals
- Convert the proven AWS infrastructure into Terraform-managed infrastructure.
- Add domain email with proper SPF, DKIM, and DMARC.
- Add diagrams for the production request path and deployment workflow.
- Improve deployment observability and rollback documentation.
- Use the website as a central portfolio for future cloud, operations, and homelab projects.

---

## Scope

This project covered:

- Building the Astro portfolio locally
- Creating a private S3 origin bucket
- Uploading static build output to S3
- Creating a CloudFront distribution
- Configuring CloudFront Origin Access Control
- Solving clean URL routing for static nested paths
- Requesting and validating an ACM certificate
- Updating Route 53 records for the domain cutover
- Validating public site behavior across multiple devices and networks
- Preserving rollback through the old Lightsail deployment
- GitHub Actions deployment automation

This project does *not* yet include:

- Terraform-managed infrastructure
- Automated rollback
- Production monitoring
- Domain email configuration

Those remain planned follow-up phases.

---

## Sanitized Resource Summary

Exact resource names and IDs are intentionally omitted from this public writeup.

| Resource | Purpose |
|---|---|
| S3 bucket | Private static origin for Astro build output |
| CloudFront distribution | Public CDN and HTTPS delivery layer |
| CloudFront OAC | Grants CloudFront access to the private S3 bucket |
| CloudFront Function | Rewrites clean URLs to `index.html` paths |
| ACM certificate | Provides TLS for `zachull.com` and `www.zachull.com` |
| Route 53 hosted zone | Manages DNS records for the domain |
| GitHub Actions workflow | Builds and deploys the Astro site on pushes to `main` |
| AWS OIDC provider | Allows GitHub Actions to assume an AWS role without long-lived keys |
| IAM deployment role | Grants scoped deployment access to S3 and CloudFront |
| Lightsail instance | Legacy WordPress host, now decommissioned |

---

## Design Decisions
### Static Site Instead of WordPress

The site is primarily a portfolio and documentation surface. It does not need comments, user accounts, server-side rendering, or CMS-driven dynamic behavior.

A static site made more sense because it is:

- Faster to serve
- Easier to version
- Lower maintenance
- Lower cost
- Easier to deploy repeatably
- Smaller from an attack-surface perspective

Astro was chosen because it provides a modern static site workflow while keeping the output simple and efficient.

---

### Private S3 Bucket Instead of Public Website Hosting

The S3 bucket was intentionally kept private.

Important S3 choices:

- Block Public Access remained enabled.
- Object Ownership was set to bucket-owner enforced.
- ACLs were disabled.
- Static website hosting was not enabled.
- SSE-S3 encryption was used.
- Bucket versioning was enabled.

CloudFront is the public access layer. S3 is only the private origin.

This design is slightly more complex than public S3 website hosting, but it is a better match for a production-style static hosting pattern.

---

### CloudFront Origin Access Control

CloudFront Origin Access Control was used so CloudFront could securely read from the private S3 bucket without exposing the bucket directly to the internet.

This avoids public-read bucket policies and keeps the public path limited to CloudFront.

---

### DNS Validation for ACM

The ACM certificate was validated through DNS because the domain is managed in Route 53.

DNS validation was preferred over email validation because it is cleaner, easier to maintain, and better suited for future automation.

---

### Manual Deployment Before Automation

The first production deployment was performed manually with the AWS CLI.

This was intentional. Before automating the deployment path, I wanted to understand and validate the architecture by hand:

```text
local build
  ↓
manual S3 sync
  ↓
CloudFront invalidation
  ↓
public validation
```

After the manual path was proven, GitHub Actions was added to automate the known-good workflow.

The current production deployment path is now:
```text
push to main
  ↓
GitHub Actions workflow
  ↓
Astro build
  ↓
AWS OIDC role assumption
  ↓
S3 sync
  ↓
CloudFront invalidation
  ↓
production validation
```

This kept the automation grounded in a process that had already been tested manually.

---

## Implementation Path
**1. Built the Local Astro Site**

The project started locally with Astro. The first stage focused on building out the actual portfolio content and structure before touching AWS.

Pages included:

- Home
- About
- Projects
- Individual project pages
- Certifications
- Resume
- Contact

The site was built to support content-driven project pages and certification entries, with Markdown content collections used for structured portfolio data.

---

**2. Connected the Project to GitHub**

The local site was connected to a private GitHub repository.

This included several Git setup issues:

- Correcting the remote URL
- Resolving SSH authentication
- Handling an existing origin
- Pulling unrelated histories from the GitHub starter repository
- Resolving conflicts between local files and the remote starter commit
- Establishing a normal change → commit → push workflow

This became the working development loop:
```text
edit locally
  ↓
test locally
  ↓
commit
  ↓
push to GitHub
```

This phase was not glamorous, but it was important. It turned the project from a local folder into a version-controlled engineering artifact.

**3. Validated the Local Build**

Before deploying anything, the site was built and previewed locally.

Commands used:
```bash
npm run build
npm run preview
```

The build generated static routes such as:
```text
/
about/
certifications/
contact/
projects/
resume/
```

Manual browser testing confirmed that the pages, links, project cards, certification links, and resume PDF all worked locally.

**4. Created the S3 Origin Bucket**

A new S3 bucket was created for the static site output.

The bucket was configured as a private CloudFront origin, not a public static website bucket.

S3 configuration:
```text
Block Public Access: enabled
Object Ownership: bucket-owner enforced
ACLs: disabled
Versioning: enabled
Default encryption: SSE-S3
Static website hosting: disabled
```

S3 Bucket Key was not enabled because the bucket uses SSE-S3, not SSE-KMS.

**5. Uploaded the Astro Build to S3**

After running:
```bash
npm run build
```

the generated dist/ output was uploaded to S3 using the AWS CLI:
```bash
aws s3 sync dist/ s3://<site-bucket-name> --delete
```

The first attempt failed because the AWS CLI was not installed locally:
```bash
zsh: command not found: aws
```

After installing and configuring the AWS CLI, the upload succeeded.

The bucket then contained the static Astro output, including:
```text
_astro/
about/
certifications/
contact/
index.html
projects/
resume/
```

One small mistake during this phase was accidentally uploading a macOS .DS_Store file. That was identified for cleanup and added to the future deployment hygiene checklist.

**6. Created the CloudFront Distribution**

A CloudFront distribution was created with the S3 bucket as the origin.

Initial CloudFront settings:
```text
Origin: S3 bucket origin
Origin access: Origin Access Control
Viewer protocol policy: Redirect HTTP to HTTPS
Allowed methods: GET, HEAD
Cache policy: CachingOptimized
Default root object: index.html
```

The free CloudFront plan was selected because the site is a low-traffic static portfolio and does not need paid WAF-heavy features at launch.

**7. Solved Initial AccessDenied Errors**

The first CloudFront test returned an S3 XML AccessDenied response.

This was expected as a possible issue because the S3 bucket was private and CloudFront access depended on OAC and the correct bucket policy.

The important decision here was not to make the bucket public.

Instead, the troubleshooting path focused on:

- Confirming files existed in S3
- Confirming the S3 bucket was intentionally private
- Confirming CloudFront had origin access
- Testing direct object paths like /index.html
- Verifying the default root object
- Waiting for CloudFront deployment changes to propagate

Once the homepage loaded through the CloudFront URL, the OAC/S3 access path was confirmed to be working.

**8. Solved Clean URL Routing**

After the homepage worked, nested routes such as:
```text
/resume/
/projects/
/certifications/
```

still failed with AccessDenied.

The reason was that CloudFront with a private S3 origin does not automatically translate:
```text
/resume/
```

into:
```text
/resume/index.html
```

To fix this, a CloudFront Function was created and attached to the viewer request event.
```JavaScript
function handler(event) {
  var request = event.request;
  var uri = request.uri;

  // Leave file requests alone: assets, PDFs, CSS, JS, images, etc.
  if (uri.includes('.')) {
    return request;
  }

  // Root path should serve /index.html
  if (uri === '/') {
    request.uri = '/index.html';
    return request;
  }

  // Directory-style route: /resume/ -> /resume/index.html
  if (uri.endsWith('/')) {
    request.uri = uri + 'index.html';
    return request;
  }

  // Extensionless route: /resume -> /resume/index.html
  request.uri = uri + '/index.html';
  return request;
}
```

This fixed clean route behavior without rewriting files such as PDFs, CSS, JavaScript, images, or other assets.

After this function was deployed, all tested CloudFront paths worked correctly.

**9. Requested the ACM Certificate**

A public ACM certificate was requested for:
```text
zachull.com
www.zachull.com
```

Configuration:
```text
Validation: DNS validation
Key algorithm: RSA 2048
Export: disabled
```

Because the domain is managed in Route 53, DNS validation records were created there and the certificate was issued.

**10. Added Custom Domains to CloudFront****

After the ACM certificate was issued, the CloudFront distribution was updated with alternate domain names:
```text
zachull.com
www.zachull.com
```

The ACM certificate was attached to the distribution.

At this stage, CloudFront was ready to serve traffic for the real domain.

**11. Updated Route 53**

Route 53 was updated to point the domain to CloudFront.

Records created:
```text
zachull.com      A     Alias → CloudFront
zachull.com      AAAA  Alias → CloudFront
www.zachull.com  A     Alias → CloudFront
www.zachull.com  AAAA  Alias → CloudFront
```

This changed the public domain path from the old Lightsail WordPress site to the new CloudFront distribution.

**12. Validated Production Behavior**

After cutover, testing showed mixed behavior across devices and networks.

Some clients loaded the new static site correctly. Others still showed the old WordPress site.

Testing confirmed:

- The CloudFront distribution URL worked directly.
- The custom domain worked on some networks.
- Route 53 showed the correct alias records.
- Devices that still showed WordPress were resolving cached DNS results.
- CloudFront invalidation did not affect DNS resolver caching.

The old Lightsail instance was kept running temporarily as rollback while DNS resolver caches aged out.

---

## Automated Deployment with GitHub Actions

After the manual deployment path was validated, the next step was to automate production updates through GitHub Actions.

The deployment workflow now runs on pushes to `main`.

The workflow performs the following steps:

```text
Check out repository
  ↓
Set up Node.js
  ↓
Install dependencies
  ↓
Build Astro site
  ↓
Assume AWS IAM role through OIDC
  ↓
Sync `dist/` to S3
  ↓
Create CloudFront invalidation
```

GitHub Actions uses AWS OpenID Connect instead of stored AWS access keys. This allows the workflow to request short-lived credentials for a scoped IAM role.

The deployment role is limited to the permissions needed for this site:

- List the site bucket
- Put, get, and delete objects in the site bucket
- Create invalidations for the CloudFront distribution

During setup, one issue came from how GitHub repository variables were entered. The variables were initially stored as KEY=value strings instead of value-only entries. This caused malformed AWS CLI commands during the workflow run.

Example of the incorrect pattern:
```text
S3_BUCKET=zachull-com-static-site
```

Correct GitHub Actions variable format:
```text
Name:  S3_BUCKET
Value: zachull-com-static-site
```

Once the variables were corrected, the workflow completed successfully and the site updated automatically after a push to main.

---

## Decommissioned the Lightsail WordPress Site

After the CloudFront-backed static site and GitHub Actions deployment pipeline were validated, the legacy Lightsail WordPress instance was decommissioned.

The old instance was kept temporarily during DNS propagation and early production validation. This provided a rollback path while confirming that Route 53, CloudFront, S3, ACM, and the deployment pipeline were all working correctly.

Once the static site was validated across multiple networks and the automated deployment pipeline completed successfully, the Lightsail resources were removed to eliminate unnecessary cost and operational overhead.

This completed the migration away from WordPress and left the static AWS architecture as the production path.

---

## Issues Encountered
### Git Setup Was Messier Than Expected

The first major friction point was not AWS. It was Git.

The local project and GitHub repository had different histories, which caused rejected pushes and merge conflicts. This required pulling unrelated histories and resolving starter-file conflicts.

Lesson:

>Source control setup is part of the project. It should be documented, not hand-waved.

### AWS CLI Was Missing Locally

The first S3 sync attempt failed because the AWS CLI was not installed on the MacBook.

Error:
```bash
zsh: command not found: aws
```

Resolution:

- Installed AWS CLI
- Configured credentials
- Verified identity
- Re-ran S3 sync

Lesson:

>A local build is not the same as a deployable workflow. The deployment machine needs its own tooling and permissions.

### S3 AccessDenied Was Expected but Still Useful

The private bucket design caused early AccessDenied responses through CloudFront.

This was not a reason to make the bucket public. It was a reason to verify OAC, root object behavior, and CloudFront deployment state.

Lesson:

>Access errors are not always failures in the architecture. Sometimes they confirm that the security boundary is actually working.

### Clean URLs Needed Explicit Handling

The biggest CloudFront/S3 routing surprise was that nested static routes did not automatically resolve to index.html.

Resolution required a CloudFront Function.

Lesson:

>Private S3 origins behave differently from S3 website endpoints. Clean URL behavior needs to be designed deliberately.

### DNS Cutover Was Not Instant Everywhere

After Route 53 was updated, some devices still saw the old WordPress site.

This happened even on devices that had not personally visited the site before, because DNS resolver caching can happen upstream at the resolver, ISP, carrier, or network level.

Lesson:

>DNS propagation is not only about browser history. Resolver caching can make different networks see different versions of the same domain during cutover.

### GitHub Actions Variables Were Misconfigured

The GitHub Actions workflow initially failed during deployment because repository variables were entered in the wrong format.

I entered values using a shell-style pattern:

```text
S3_BUCKET = zachull-com-static-site
```

But GitHub Actions repository variables already separate the variable name from the value. The correct value should contain only the value itself.

Correct pattern:
```text
Variable name:  S3_BUCKET
Variable value: zachull-com-static-site
```

The same issue affected other variables such as the AWS region and CloudFront distribution ID.

Lesson:

>GitHub Actions variables should store only the value. The variable name belongs in the GitHub variable name field, not inside the variable value.

---

## High Points
### The Static Site Became a Real Cloud Project

This stopped being “just a website” once the deployment path included:

- Private S3 origin
- CloudFront delivery
- Origin Access Control
- Route 53 alias records
- ACM certificate validation
- Clean URL rewrites
- DNS cutover planning
- Rollback strategy

The site itself became evidence of the infrastructure work.

### CloudFront Function Solved a Real Production Issue

The clean URL problem was a practical routing issue that required understanding how CloudFront and private S3 origins interact.

Solving it made the final architecture stronger and more professional.

### The Resume, Projects, and Certifications Became Version-Controlled

The site content now lives in Git instead of inside a WordPress admin panel.

That means updates can be:

- Reviewed
- Committed
- Reverted
- Automated later
- Documented through Git history

This was one of the most valuable shifts in the project.

### The Cutover Worked Without Making S3 Public

Keeping the bucket private preserved the intended security model.

The final public path is CloudFront, not direct S3 access.

### The Deployment Pipeline Became Fully Automated

After the manual deployment path was validated, GitHub Actions was added to build and deploy the site automatically.

The site can now be updated through the normal Git workflow:

```text
edit content
  ↓
commit
  ↓
push to main
  ↓
GitHub Actions deploys to production
```

This moved the project from a manually deployed static site to a more complete CI/CD workflow.

## Low Points
### The Project Took Longer Than a Simple Website Should

A seasoned engineer could likely build the basic version quickly. For me, the value was in working through each layer intentionally.

The slow parts were:

- Git setup and repo history cleanup
- CSS issues and revisions
- Astro content collection behavior
- AWS CLI setup
- CloudFront/S3 permissions
- Clean URL routing
- DNS cutover validation

Those slow points are also where most of the learning happened.

### Debugging Was Spread Across Several Systems

Troubleshooting required moving between:

- Local dev server
- Astro build output
- GitHub
- S3 bucket contents
- CloudFront settings
- CloudFront Functions
- ACM validation
- Route 53 records
- Device DNS behavior

This made the project feel messy at times, but it also made the final product more rewarding.

### DNS Behavior Was Frustrating

Once the CloudFront distribution worked and Route 53 looked correct, it was frustrating to still see the old WordPress site on some devices.

The resolution was not another AWS configuration change. It was recognizing DNS resolver caching and waiting safely while preserving rollback.

---

## Validation Checklist

The CloudFront distribution was validated directly before DNS cutover.

Validated paths:
```text
/
 /projects/
 /certifications/
 /resume/
 /about/
 /contact/
 /resume/zachery-hull-resume.pdf
```

After Route 53 cutover, validation continued across:
```text
https://zachull.com/
https://www.zachull.com/
```

Additional testing included:

- Laptop browser
- Phone browser
- Cellular network
- Alternate device
- Direct CloudFront distribution URL

---

## Current State

The project is now in production and the legacy Lightsail WordPress deployment has been decommissioned.

**Completed:**

- Astro site built locally
- Source committed to GitHub
- Static files uploaded to S3
- S3 bucket kept private
- CloudFront distribution created
- OAC configured
- CloudFront Function deployed
- ACM certificate issued
- Route 53 alias records updated
- CloudFront paths validated
- Custom domain validated
- GitHub Actions deployment workflow completed
- AWS OIDC role assumption configured
- Automated S3 sync and CloudFront invalidation working
- Legacy Lightsail WordPress resources decommissioned

**Still in progress:**

- Terraform conversion
- Architecture diagrams
- Production monitoring considerations
- Domain email configuration
- Additional runbooks for smaller operational workflows

**Rollback and Decommission Strategy**

After the new static site and automated deployment pipeline were validated, the legacy Lightsail instance was decommissioned.

The rollback period is now complete. Future rollback planning should focus on:

- Reverting Git changes
- Re-running the GitHub Actions deployment workflow
- Restoring previous S3 object versions if needed
- Using CloudFront invalidations after rollback
- Documenting Terraform state and recovery once IaC is introduced

---

## Completed Phase: Deployment Automation

The original deployment path was manual:
```bash
npm run build
aws s3 sync dist/ s3://<site-bucket-name> --delete
aws cloudfront create-invalidation --distribution-id <distribution-id> --paths "/*"
```

This phase has now been completed through GitHub Actions and AWS OIDC.

The current deployment path is:

```text
Push to main
  ↓
GitHub Actions installs dependencies
  ↓
Astro builds the site
  ↓
GitHub authenticates to AWS using OIDC
  ↓
dist/ syncs to S3
  ↓
CloudFront invalidation runs
  ↓
zachull.com updates automatically
```

Planned automation tasks:

- Future Infrastructure as Code Phase

Now that the manual and automated deployment paths are stable, the infrastructure should be converted to Terraform.

Potential Terraform-managed resources:

- S3 bucket
- S3 bucket policy
- CloudFront distribution
- CloudFront Function
- ACM certificate reference
- Route 53 records
- IAM role for GitHub Actions OIDC
- Deployment permissions

This will move the project from manually configured AWS infrastructure toward repeatable infrastructure as code.

### Future Domain Operations Work

A related future project is configuring professional email for zachull.com.

Planned scope:

- Mail provider selection
- MX records
- SPF
- DKIM
- DMARC
- Deliverability testing
- Resume/contact email updates
- Documentation of DNS authentication records

This will extend the domain from just website hosting into broader domain operations.

---

## Lessons Learned
### A Portfolio Site Can Be Infrastructure Evidence

The strongest version of this project is not the website alone. It is the deployment architecture, documentation, and operational reasoning around the website.

The site became a way to demonstrate:

- Cloud hosting
- DNS
- TLS
- Static build workflows
- S3 permissions
- CloudFront behavior
- Cutover planning
- Troubleshooting
- Rollback thinking
### Manual First, Automation Second Was the Right Choice

It would have been tempting to automate immediately, but manually building the path first made the architecture easier to understand.

Automation will be stronger now because it will automate a known-good process instead of hiding uncertainty behind a workflow file.

### Private S3 Origins Require More Thought

Using S3 privately behind CloudFront is the better security model for this project, but it requires more understanding than simply enabling public S3 website hosting.

The clean URL rewrite requirement was the most important example of that tradeoff.

### DNS Cutovers Require Patience

Even when Route 53 is correct, clients may not all see the new site immediately.

A good cutover plan needs:

- validation from multiple networks
- rollback infrastructure
- patience with resolver caching
- no unnecessary destructive changes

### Documentation Should Follow the Work

This project produced useful documentation because the issues were captured as they happened.

The most valuable parts of the writeup are not only the success path, but the friction points:

- Git history issues
- AWS CLI missing locally
- S3 AccessDenied
- clean URL failures
- DNS resolver delay

Those are the details that make the project real.

## Final Notes

This migration is now a working production cloud project, but it is not finished.

The current system is functional, secure by default, publicly reachable, and automatically deployed through GitHub Actions.

The next major improvement is converting the manually configured AWS resources into Terraform so the infrastructure can be recreated, reviewed, and evolved as code.

The project is a good example of the kind of infrastructure work I want to keep building: practical, documented, cost-aware, and designed to become more reliable over time.