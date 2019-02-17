import os

from sqlalchemy import Column, Integer, Sequence, String, create_engine

from sqlalchemy.orm import relationship, scoped_session, sessionmaker

from sqlalchemy.ext.declarative import declarative_base

POSTGRES_CONNECTION_STRING = os.environ.get('DATABASE_URL')

engine = create_engine(
    POSTGRES_CONNECTION_STRING, convert_unicode=True
)


db_session = scoped_session(sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine
))


Base = declarative_base()
Base.query = db_session.query_property()


def init_db():
    # import all modules here that might define models so that
    # they will be registered properly on the metadata.  Otherwise
    # you will have to import them first before calling init_db()
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    db_session.commit()
