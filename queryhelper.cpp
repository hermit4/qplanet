#include "queryhelper.h"
#include <QFile>
#include <QBuffer>

QueryHelper::QueryHelper(const QString& queryPath, QObject* parent)
           : QObject(parent), queryFile_(queryPath)
{
}

QueryHelper::~QueryHelper()
{
}

void QueryHelper::bindVariable(const QString& name, const QByteArray& src)
{
    QBuffer* buf = new QBuffer(this); // delete by ~QObject()
    buf->setData(src);
    buf->open(QIODevice::ReadOnly);
    query_.bindVariable(name, buf);
}

void QueryHelper::bindVariable(const QString& name, const QVariant& any)
{
#if 0
    QXmlQuery query;
    query.setQuery(QString("doc(%1)").arg(docUrl));
    query_.bindVariable(name, query);
#endif
    query_.bindVariable(name, any);
}

QByteArray QueryHelper::evaluate()
{
    QBuffer buf;
    buf.open(QIODevice::WriteOnly);
    if (!queryFile_.open(QIODevice::ReadOnly)) {
        return buf.data();
    }
    query_.setQuery(&queryFile_);
    query_.evaluateTo(&buf); 
    return buf.data();
}

QString QueryHelper::evaluateToStr()
{
    QString ret;
    if (!queryFile_.open(QIODevice::ReadOnly)) {
        return ret;
    }
    query_.setQuery(&queryFile_);
    query_.evaluateTo(&ret); 
    return ret;
}
