# Google Cloud Platform Setup
- Follow the <a aria-label="See Google Cloud S D K installation instructions" href="https://cloud.google.com/sdk/docs/install" target="_blank" rel="nofollow noopener"><code>gcloud</code> installation instructions</a> for your platform.
- Log into your account with the <code>gcloud init</code> command.
- Define environment variables:
```bash
export PROJECT_NAME="lappland-vpn"
export PROJECT_ID="lappland-vpn-"`date +%F`
export BILLING_ID="<enter-your-billing-account-here>"
export CREDENTIALS="~/.config/gcloud/lappland-"`date +%F`.json
```
- Create a project and associate a billing account with it:
```bash
gcloud projects create ${PROJECT_ID} --name ${PROJECT_NAME} \
  --set-as-default
gcloud beta billing projects link ${PROJECT_ID} \
  --billing-account ${BILLING_ID}
```

- Create a service account with credentials (subsititute your-gcloud-account, typically the email of the account you use to administer gcloud):
```bash
gcloud iam service-accounts create lappland-vpn --display-name "Lappland VPN"
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member user:<your-gcloud-account> \
  --role roles/iam.serviceAccountAdmin
$ gcloud iam service-accounts keys create ${CREDENTIALS} \
  --iam-account lappland-vpn@${PROJECT_ID}.iam.gserviceaccount.com
$ gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member serviceAccount:lappland-vpn@${PROJECT_ID}.iam.gserviceaccount.com \
  --role roles/compute.admin
$ gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member serviceAccount:lappland-vpn@{PROJECT_ID} \
  iam.gserviceaccount.com \
  --role roles/iam.serviceAccountUser
```
**Attention**: take care of the credentials file, which contains the credentials to manage your Google Cloud account, including create and delete servers on this project.

- Enable the compute service:
```bash
gcloud services enable compute.googleapis.com
```
