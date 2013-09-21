#pragma once

/*
   XQuery Helper class.
    QXmlQuery have bindVariable with QXmlQuery class, but 
    the bind cause unknown crash.
    So, I try bind with QBuffer.
 */

#include <QObject>
#include <QFile>
#include <QXmlQuery>

class QByteArray;
class QString;
class QVariant;

class QueryHelper : public QObject
{
    Q_OBJECT
public:
    QueryHelper(const QString& path,QObject* parent=0);
    ~QueryHelper();
    void bindVariable(const QString& name, const QByteArray& src);
    void bindVariable(const QString& name, const QVariant& any);
    QByteArray evaluate();
    QString    evaluateToStr();

private:
    QFile     queryFile_;
    QXmlQuery query_;
};
