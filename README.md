# Loris

**Deprecation notice**

As of March 2021, Wellcome Collection no longer run an instance of Loris to serve our IIIF image API.

We are using https://dlcs.info/ to serve the content previously hosted by Loris.

This repository contains the Docker image definitions and infrastructure for our [Loris] deployment.

[Loris]: https://github.com/loris-imageserver/loris

---

## How to update our Loris image

1.  Edit the `LORIS_GITHUB_USER` and `LORIS_COMMIT` variables [in the Dockerfile](https://github.com/wellcomecollection/loris-infrastructure/blob/master/loris/Dockerfile#L18-L19).
    This will install Loris from the following URL:

    https://github.com/:LORIS_GITHUB_USER/loris/commit/:LORIS_COMMIT

    Note: `LORIS_GITHUB_USER` should be `loris-imageserver` (the upstream Loris repo) unless we're temporarily deploying from a fork.

2.  Run `make loris-publish` from the root of the repo.

3.  Plan and apply the terraform in the `terraform` directory.

## Testing Loris with nginx

In order to test Loris with its nginx config this project provides a `docker-compose.yml`

This can be run using (substituting env variables as necessary):

### docker-compose

This starts both loris and nginx (at the tag specified), using the config file specified.

```sh
NGINX_TAG=latest docker-compose up
```

### curl localhost:9000

You can then query the local version of loris (in order to avoid redirects it's necessary to use the `ELB-HealthChecker/2.0` User-Agent).

```sh
curl \
    --user-agent ELB-HealthChecker/2.0 \
    --verbose \
    --output default.jpg \
    http://localhost:9000/image/V0017087.jpg/full/300,/0/default.jpg
```
