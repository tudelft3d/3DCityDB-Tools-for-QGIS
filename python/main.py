import os, sys
import psycopg2, psycopg2.sql as pysql
import pandas as pd
from psycopg2.extras import LoggingConnection, LoggingCursor
import logging
import db_tools

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)