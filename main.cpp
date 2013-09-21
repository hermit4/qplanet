#include <QCoreApplication>
#include <QFile>
#include <QDir>
#include <QByteArray>
#include <QTextStream>
#include <QStringList>
#include "queryhelper.h"

QByteArray aggregate(const QString& query, const QString& registrant)
{
    QueryHelper helper(query);
    helper.bindVariable("registrant", QVariant(registrant));
    return helper.evaluate();
}

QByteArray toArticles(const QString& query, QByteArray aggregated)
{
    QueryHelper helper(query);
    helper.bindVariable("aggregated", aggregated);
    return helper.evaluate();
}

QString toHtml(const QString& query, QByteArray aggregated, QByteArray articles)
{
    QueryHelper helper(query);
    helper.bindVariable("subscriptions", aggregated);
    helper.bindVariable("articles", articles);
    QString ret = helper.evaluateToStr();
    ret.replace("&gt;",">")
       .replace("&lt;","<")
       .replace("&quot;","\"")
       .replace("&amp;","&");

    return ret;
}

// Sorry Linux only yet.
QString findConfig(const QString& fileName)
{
    QStringList list = QStringList() << "./etc/"
                                     << "/usr/local/etc/qplanet"
                                     << "/usr/etc/qplanet"
                                     << "/etc/qplanet";
    foreach(QString dir, list) {
        QDir d(dir);
        if (d.exists(fileName)) {
            return d.filePath(fileName);
        }
    }
    return QDir(list.first()).filePath(fileName);
}

int main(int argc, char* argv[])
{
    QCoreApplication app(argc, argv);

    QString aggregateQuery = ":/query/aggregate.xq";
    QString articlesQuery  = ":/query/articles.xq";

    QString templateQuery  = findConfig("template.xq");
    QString registrant     = findConfig("regist.xml");

    QByteArray aggregated = aggregate(aggregateQuery, registrant);
    QByteArray articles   = toArticles(articlesQuery,aggregated);
    QString    html       = toHtml(templateQuery, aggregated, articles);
    QTextStream(stdout) << html << endl;
    return 0;
}
