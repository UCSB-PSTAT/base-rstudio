UCSB RStudio Base
=================

Base image for launching RStudio via JupyterHub.  This based on the [Jupyter R upstream](https://hub.docker.com/r/jupyter/r-notebook) and adds features and libraries commonly used in data science lab courses at [UCSB](https://ucsb.edu) that make use of [RStudio](https://www.rstudio.com/).  In addition, these builds also include updates to the base OS image as available at the time of build.

## How to run

The most basic way to demo this locally: 

`podman -it -p8888:8888 ucsb/rstudio-base:latest`

In the stdout, there will be a link that includes a token that will allow you to login locally with a browser.  To get to rstudio, visit the /rstudio path.

Generally, refer to [upstream documentation](https://jupyter-docker-stacks.readthedocs.io/en/latest/) for running these containers, however, this container adds an additional /rstudio endpoint with the necessary [jupyter session proxy](https://github.com/jupyterhub/jupyter-rsession-proxy) layer, making it suitable to deploy via [JupyterHub helm chart](https://zero-to-jupyterhub.readthedocs.io/en/latest/) or as a standalone deployment.

## How to build an image from this

In order to build a downstream image, the user should be first set to root, and then reset back once changes are complete:

```
FROM ucsb/rstudio-base:latest

USER root

# Add your changes here
RUN mamba install ...
RUN R -e "install.packages(c('<library>', '<library>'), repos = 'https://cloud.r-project.org/', Ncpus = parallel::detectCores())"
USER $NB_USER
```

## Tags

`latest` - Periodically a Jupyter release version is tagged in the Containerfile and this tags tracks the most recent build against that particular version.  That upstream version may get updated at least quarterly.  This image is built and tested at least weekly.

`weekly` - This tag is primarily for integration testing and tracks the upstream `latest` tag.  These images are generally built, tested, and updated weekly on Monday mornings (PDT time).

`v...` - The numbers in these tags represent a date and are effectively a snapshot of the `latest` tag as it was on that particular day.  


## Package List

Please note that the list provided here is only updated periodically. 

You can get the definitive list and specific versions that are installed by running: `podman run -it --rm --user 0 --pull=Always ucsb/rstudio-base:latest sh -c "Rscript -e 'installed.packages()'; pip list"` Replacing the `latest` with another valid published tag will allow you to check that specific version instead. 


### Python Modules
ai21, aiohappyeyeballs, aiohttp, aiolimiter, aiosignal, alembic, annotated-doc, annotated-types, anthropic, anyio, archspec, argon2-cffi, argon2-cffi-bindings, arrow, arxiv, asttokens, async-lru, attrs, babel, backports.zstd, bce-python-sdk, beautifulsoup4, bleach, blinker, boltons, boto3, botocore, Bottleneck, Brotli, cached-property, cachetools, certifi, certipy, cffi, charset-normalizer, click, cloudpickle, cohere, comm, conda, conda-libmamba-solver, conda-package-handling, conda_package_streaming, contourpy, crc32c, cryptography, cycler, dask, dataclasses-json, debugpy, decorator, deepmerge, defusedxml, detect_agent, dill, diskcache, distributed, distro, docstring_parser, exceptiongroup, executing, faiss-cpu, fastavro, fastjsonschema, feedparser, filelock, filetype, fonttools, fqdn, frozendict, frozenlist, fsspec, future, google-ai-generativelanguage, google-api-core, google-auth, google-cloud-aiplatform, google-cloud-bigquery, google-cloud-core, google-cloud-resource-manager, google-cloud-storage, google-crc32c, google-genai, google-resumable-media, googleapis-common-protos, gpt4all, greenlet, grpc-google-iam-v1, grpcio, grpcio-status, h11, h2, hf-xet, hpack, httpcore, httpx, httpx-sse, huggingface_hub, hyperframe, idna, importlib_metadata, importlib_resources, ipykernel, ipython, ipython_genutils, ipython_pygments_lexers, ipywidgets, isoduration, jedi, Jinja2, jiter, jmespath, json5, jsonpatch, jsonpath-ng, jsonpointer, jsonschema, jsonschema-specifications, jupyter_ai, jupyter_ai_magics, jupyter_client, jupyter_core, jupyter-events, jupyter-lsp, jupyter-rsession-proxy, jupyter_server, jupyter_server_proxy, jupyter_server_terminals, jupyterhub, jupyterlab, jupyterlab_pygments, jupyterlab_server, jupyterlab_widgets, kiwisolver, langchain, langchain-anthropic, langchain-aws, langchain-cohere, langchain-community, langchain-core, langchain-google-genai, langchain-google-vertexai, langchain-mistralai, langchain-nvidia-ai-endpoints, langchain-ollama, langchain-openai, langchain-text-splitters, langsmith, lark, libmambapy, locket, Mako, markdown-it-py, MarkupSafe, marshmallow, matplotlib, matplotlib-inline, mdurl, menuinst, mistune, msgpack, multidict, multiprocess, mypy_extensions, nbclassic, nbclient, nbconvert, nbformat, nbgitpuller, nest_asyncio, notebook, notebook_shim, numexpr, numpy, oauthlib, ollama, openai, orjson, overrides, packaging, pamela, pandas, pandocfilters, parso, partd, pexpect, pillow, pip, platformdirs, pluggy, prometheus_client, prompt_toolkit, propcache, proto-plus, protobuf, psutil, ptyprocess, pure_eval, pyarrow, pyasn1, pyasn1_modules, pycosat, pycparser, pycryptodome, pydantic, pydantic_core, pydantic-settings, Pygments, PyJWT, pyparsing, pypdf, PySocks, python-dateutil, python-dotenv, python-json-logger, PyYAML, pyzmq, qianfan, referencing, regex, requests, requests-toolbelt, rfc3339_validator, rfc3986-validator, rfc3987-syntax, rich, rpds-py, ruamel.yaml, ruamel.yaml.clib, s3transfer, Send2Trash, setuptools, sgmllib3k, shellingham, simpervisor, six, sniffio, sortedcontainers, soupsieve, SQLAlchemy, stack_data, tabulate, tblib, tenacity, terminado, tiktoken, tinycss2, together, tokenizers, tomli, toolz, tornado, tqdm, traitlets, truststore, typer, types-PyYAML, types-requests, types-tabulate, types-tqdm, typing_extensions, typing-inspect, typing-inspection, typing_utils, tzdata, uri-template, urllib3, uuid_utils, validators, wcwidth, webcolors, webencodings, websocket-client, websockets, widgetsnbextension, xxhash, yarl, zict, zipp, zstandard
### R Libraries
abind, askpass, assertthat, backports, base, base64enc, bayesplot, BH, bit, bit64, bitops, blob, bmp, boot, brew, bridgesampling, brio, brms, Brobdingnag, broom, bslib, cachem, callr, car, carData, caret, cellranger, checkmate, class, cli, cliapp, clipr, clock, coda, codetools, colorspace, commonmark, compiler, conflicted, covr, cowplot, cpp11, crayon, credentials, curl, data.table, datasets, DBI, dbplyr, Deriv, desc, devtools, diagram, dials, DiceDesign, diffobj, digest, distributional, doBy, docopt, downlit, downloader, dplyr, dtplyr, e1071, effsize, ellipsis, evaluate, fansi, faraway, farver, fastmap, filelock, fontawesome, forcats, foreach, forecast, Formula, fracdiff, fs, furrr, future, future.apply, gargle, gbm3, generics, gert, ggplot2, ggridges, gh, gitcreds, globals, glue, googledrive, googlesheets4, gower, GPfit, graphics, grDevices, grid, gridExtra, gtable, hardhat, harrypotter, haven, hexbin, highr, hms, htmltools, htmlwidgets, httpuv, httr, httr2, ids, igraph, imager, infer, ini, inline, ipred, IRdisplay, IRkernel, isoband, iterators, jpeg, jquerylib, jsonlite, KernSmooth, knitr, labeling, later, lattice, lava, lhs, lifecycle, listenv, littler, lme4, lmtest, loo, lpSolve, lubridate, magrittr, MASS, Matrix, MatrixModels, matrixStats, memoise, methods, mgcv, microbenchmark, mime, miniUI, minqa, modeldata, modelenv, ModelMetrics, modelr, munsell, mvtnorm, nleqslv, nlme, nloptr, nnet, numDeriv, nycflights13, openssl, otel, ottr, pak, parallel, parallelly, parsnip, patchwork, pbdZMQ, pbkrtest, pillar, pkgbuild, pkgcache, pkgconfig, pkgdown, pkgload, plogr, plyr, png, posterior, praise, prettycode, prettyunits, pROC, processx, prodlim, profvis, progress, progressr, promises, proxy, ps, pscl, purrr, quadprog, quantmod, quantreg, QuickJSR, R6, ragg, randomForest, rappdirs, rbibutils, rcmdcheck, RColorBrewer, Rcpp, RcppArmadillo, RcppEigen, RcppParallel, RCurl, Rdpack, readbitmap, readr, readxl, recipes, reformulas, rematch, rematch2, remotes, repr, reprex, reshape2, rex, rlang, rmarkdown, Rmisc, RODBC, roxygen2, rpart, rprojroot, rsample, RSQLite, rstan, rstantools, rstudioapi, rversions, rvest, S7, sass, scales, selectr, sessioninfo, sfd, shape, shiny, slider, sourcetools, SparseM, sparsevctrs, splines, SQUAREM, StanHeaders, stargazer, stats, stats4, stringi, stringr, survival, sys, systemfonts, tailor, tcltk, tensorA, testthat, textshaping, tibble, tidymodels, tidyr, tidyselect, tidyverse, tiff, timechange, timeDate, tinytex, tools, tseries, TTR, tune, tzdb, urca, urlchecker, usethis, utf8, utils, uuid, vcd, vctrs, viridisLite, vroom, waldo, warp, WDI, whisker, withr, workflows, workflowsets, xfun, xml2, xopen, xtable, xts, yaml, yardstick, zip, zoo
