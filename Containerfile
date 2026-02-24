ARG BASE_IMAGE=quay.io/fedora/fedora-bootc:43

FROM scratch AS ctx
COPY build_files /ctx
FROM ${BASE_IMAGE} AS dpu-sim-base
RUN --mount=type=cache,dst=/var/cache/dnf \
    --mount=type=cache,dst=/var/cache \
    --mount=type=bind,from=ctx,src=/ctx,dst=/ctx \
    /ctx/install-common.sh
RUN bootc container lint

FROM dpu-sim-base AS dpu-sim-control-plane
RUN --mount=type=cache,dst=/var/cache/dnf \
    --mount=type=cache,dst=/var/cache \
    --mount=type=bind,from=ctx,src=/ctx,dst=/ctx \
    /ctx/install-control-plane.sh && \
    /ctx/cleanup.sh
RUN bootc container lint

FROM dpu-sim-base AS dpu-sim-worker
RUN --mount=type=cache,dst=/var/cache/dnf \
    --mount=type=cache,dst=/var/cache \
    --mount=type=bind,from=ctx,src=/ctx,dst=/ctx \
    /ctx/install-worker.sh && \
    /ctx/cleanup.sh
RUN bootc container lint
