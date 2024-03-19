FROM public.ecr.aws/codebuild/amazonlinux2-x86_64-standard:4.0
ENV TERRAFORM_VERSION=1.7.4
ENV GO_VERSION=1.20.2
ENV YQ_VERSION=v4.34.1
RUN cd /tmp && \
    wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin && chmod 755 /usr/local/bin/terraform

RUN cd /tmp && \
    wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
<<<<<<< before updating
    tar -C /usr/local/bin -xzf go${GO_VERSION}.linux-amd64.tar.gz && chmod 755 /usr/local/bin/go

RUN pip3 install checkov

RUN wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 -O /usr/bin/yq && \
    chmod +x /usr/bin/yq
=======
    tar -C /usr/local/bin -xzf go${GO_VERSION}.linux-amd64.tar.gz && chmod 755 /usr/local/bin/go
>>>>>>> after updating
