# LaTeX environment for Japanese letter address
FROM texlive/texlive:latest

# Install Japanese fonts and additional packages
RUN apt-get update && \
    apt-get install -y \
    fonts-noto-cjk \
    fonts-noto-cjk-extra \
    git \
    && rm -rf /var/lib/apt/lists/*

# Clone jletteraddress repository
RUN git clone https://github.com/ueokande/jletteraddress.git /opt/jletteraddress

# Set working directory
WORKDIR /workdir

# Default command
CMD ["bash"]

