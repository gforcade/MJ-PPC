﻿# -*- coding: utf-8 -*-

import os
from setuptools import setup

# Utility function to read the README file.
def read(fname):
    return open(os.path.join(os.path.dirname(__file__), fname)).read()

descrip = ("Simulate light propagation in multilayer thin and/or thick "
           "films using the fresnel equations and transfer matrix "
           "method.")

data_files = ['README.txt','LICENSE.txt','Changes.txt','manual.pdf']

setup(
    name = "tmm",
    version = '0.1.1',
    author = "Steven Byrnes",
    author_email = "steven.byrnes@gmail.com",
    description = descrip,
    license = "MIT",
    keywords = "optics, fresnel, reflection, absorption, photovoltaics, ellipsometry, transfer matrix method",
    url = "http://pypi.python.org/pypi/tmm",
    packages=['tmm'],
    package_data={'tmm':data_files},
    package_dir={'tmm': '.'},
    long_description=read('README.txt'),
    install_requires=["numpy", "scipy"], 
    classifiers=[
        "Intended Audience :: Science/Research",
        "Topic :: Scientific/Engineering",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 2"],
)
