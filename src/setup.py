# # setup.py
# from setuptools import setup, find_packages
# setup(
#     name = "ynh",
#     version = "0.1",
#     packages = find_packages()
#     )

import setuptools
 
# with open("README.md", "r") as fh:
#     long_description = fh.read()
 
setuptools.setup(
    name="yunohost",
    version="0.0.1",
    author="YunoHost",
    author_email="postmaster@yunohost.org",
    description="Package to create YunoHost",
    # long_description=long_description,
    # long_description_content_type="text/markdown",
    packages=setuptools.find_packages(),
    classifiers=[
        "Programming Language :: Python :: 3",
        # "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    python_requires='>=3.9',
)