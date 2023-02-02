## Build

In my experience pushing a locally built multi-arch image often failed. I suspect this is due to slow 
upload speed on the internet connection used. 
[Github actions](https://docs.github.com/en/actions) worked.

### Github actions buildx 

* [buildx workflow](https://github.com/Quodatum/basex-docker/actions/workflows/buildx.yml)
* [buildx code](https://github.com/Quodatum/basex-docker/blob/main/.github/workflows/buildx.yml)

