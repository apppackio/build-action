# AppPack Build GitHub Action

This action builds an [AppPack](https://apppack.io) app image directly on GitHub. AWS credentials are required to make the necessary API calls.

## Inputs

### `appname`

**Required** Name of the AppPack app

## Outputs

### `docker_image`

Tagged Docker image created during the build process

## Example usage

```yaml
- name: AppPack Build
  id: build
  uses: apppackio/build-action@v1
  with:
    appname: my-app
  env:
    AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
    AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    AWS_REGION: us-east-1
```

In later steps, you will be able to reference the outputs from this action. For example, to get the docker image, you could do:

```
${{ steps.build.outputs.docker_image }}
```
