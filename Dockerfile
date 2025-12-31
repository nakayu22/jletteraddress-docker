# LaTeX environment for Japanese letter address
FROM texlive/texlive:latest

# Install Japanese fonts and additional packages
RUN apt-get update && \
    apt-get install -y \
    fonts-noto-cjk \
    fonts-noto-cjk-extra \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workdir

# Default command
CMD ["bash"]

