# Composer Package Test Utility

This utility helps you test Python package dependencies for Google Cloud Composer compatibility. It allows you to check the dependencies of a package and build a Docker image to verify compatibility with a specific Composer version.

## The Problem

Google Cloud Composer environments come with a specific set of pre-installed Python packages. When you add your own Python dependencies, you risk creating version conflicts with these pre-installed packages. For example, a new package you add might require a newer version of a library than the one installed in the Composer environment. Furthermore, if you try to add a package that is not compatible with the running Composer environment, the environment update operation itself can fail, potentially leading to downtime.

These dependency conflicts can cause your Airflow DAGs to fail in subtle or non-obvious ways, and troubleshooting them within a live Composer environment can be difficult and time-consuming.

This utility solves the problem by allowing you to test your package dependencies in a local Docker environment that closely mimics a real Cloud Composer environment _before_ you deploy them. This helps you catch and resolve conflicts early in the deployment process.

## Features

- Check the dependencies of a Python package from PyPI.
- Build a Docker image with a `requirements.txt` file to test compatibility with a Cloud Composer image.

## Getting Started

### Prerequisites

- Docker installed on your local machine.
- Python 3.

### Usage

#### 1. Check Package Dependencies

You can use the `check_dependencies.py` script to inspect the dependencies of a package before adding it to your `requirements.txt`.

1.  Open `check_dependencies.py`.
2.  Set the `name` and `version` variables for the package you want to check.
    ```python
    name = 'gcloud-aio-auth'
    version = '4.2.1'
    ```
3.  Run the script:
    ```sh
    python check_dependencies.py
    ```
    This will print the package's distribution requirements and the required Python version.

    **Example Output:**

    ```
    ['aiohttp (<4.0.0,>=3.7.1)', 'google-auth (<3.0.0,>=2.3.2)', 'cryptography (<41.0.0,>=2.0.0)']
    >=3.7
    ```

    This tells you that `gcloud-aio-auth==4.2.1` depends on specific versions of `aiohttp`, `google-auth`, and `cryptography`.

#### 2. Test Compatibility with Cloud Composer

1.  Add your desired packages to `requirements.txt`. It is highly recommended to pin the versions of your dependencies.
    ```
    # requirements.txt
    gcloud-aio-auth==4.2.1
    cryptography==38.0.4
    ...
    ```

2.  Build the Docker image. This will use the `Dockerfile` and `installer.sh` script to install the packages from `requirements.txt` on top of a Cloud Composer image. You can find details about the base images for different Cloud Composer versions [here](https://docs.cloud.google.com/composer/docs/composer-versions).
    ```sh
    docker build --build-arg COMPOSER_PYTHON_VERSION=3 -t composer-package-test .
    ```
    You can also specify a different composer image by using the `COMPOSER_IMAGE` build argument:
    ```sh
    docker build --build-arg COMPOSER_PYTHON_VERSION=3 --build-arg COMPOSER_IMAGE=<your-composer-image> -t composer-package-test .
    ```

3.  Analyze the build output.

    -   **Successful Build:** If the Docker build completes successfully, your packages are likely compatible with the base Composer image.
    -   **Failed Build:** If the build fails, the output will show the dependency conflicts that need to be resolved.

    **Example of a Failed Build:**

    ```
    #8 23.01 cloud-sql-python-connector 1.2.2 has requirement cryptography>=38.0.3, but you have cryptography 36.0.2.
    executor failed running [/bin/sh -c bash installer.sh $COMPOSER_PYTHON_VERSION  fail]: exit code: 1
    ```

    This error indicates that `cloud-sql-python-connector` requires `cryptography>=38.0.3`, but an older version (`36.0.2`) is present in the environment. To fix this, you would need to adjust the versions in your `requirements.txt` to satisfy all dependencies.

## Contributing

Contributions are welcome! Please read our [CONTRIBUTING.md](CONTRIBUTING.md) for details on how to contribute to this project.

## Code of Conduct

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Steps:

1.  use check_dependencies.py file to check the package dependencies if any (for eg: gcloud-aio-auth:latest has 'cryptography (>=2.0.0,<41.0.0)')

2.  specify the package list in requirements.txt file , make sure to pin the version number (mandatory- to avoid future build issues)

3.  Run docker build --build-arg COMPOSER_PYTHON_VERSION=3 . to build image if all the new installed packages are compatatible with composer 2.4.3 image then build will be sucess , otherwise it will throw error (eg : python3 -m pip check #8 23.01 cloud-sql-python-connector 1.2.2 has requirement cryptography>=38.0.3, but you have cryptography 36.0.2.executor failed running [/bin/sh -c bash installer.sh $COMPOSER_PYTHON_VERSION fail]: exit code: 1)