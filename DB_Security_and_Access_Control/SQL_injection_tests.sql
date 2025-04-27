-- Bu bölümde, MSSQL üzerinde basit SQL Injection senaryolarını simüle ederek
-- zafiyetleri ve korunma yöntemlerini inceleyeceğiz.

-- ---------------------------------------------
-- 3.1: Zafiyetli Arama Sorgusu Simülasyonu
-- ---------------------------------------------
-- Aşağıdaki örnek, kullanıcıdan alınan bir isme göre Airbnb odalarını arayan
-- güvenli olmayan bir sorguyu simüle etmektedir. Kullanıcı girdisi doğrudan
-- SQL sorgusuna eklenmektedir.
DECLARE @searchName NVARCHAR(255);
SET @searchName = '<Kullanıcının Girdiği İsim>'; -- Kullanıcının arama kutusuna yazdığı değer

DECLARE @sql NVARCHAR(MAX);
SET @sql = 'SELECT * FROM Airbnb_Cleaned_Final WHERE name LIKE ''%' + @searchName + '%''';

-- Güvenli olmayan sorguyu çalıştırma (UYGULAMAYIN - SADECE SİMÜLASYON)
-- EXEC (@sql);

-- ---------------------------------------------
-- 3.2: Normal Arama
-- ---------------------------------------------
-- Kullanıcının normal bir arama terimi girmesi durumu.
-- Aşağıdaki örnekte, arama terimi olarak 'Luxury' kullanıyoruz.

DECLARE @searchName_normal NVARCHAR(255);
SET @searchName_normal = 'Luxury';

DECLARE @sql_normal NVARCHAR(MAX);
SET @sql_normal = 'SELECT * FROM Airbnb_Cleaned_Final WHERE name LIKE ''%' + @searchName_normal + '%''';
EXEC (@sql_normal);
GO

-- Bu sorguyu çalıştırdığınızda, 'name' sütununda 'Luxury' kelimesi geçen
-- tüm Airbnb kayıtlarını görmelisiniz. Bu, uygulamanın normal bir
-- senaryoda nasıl çalıştığını gösterir.

-- ---------------------------------------------
-- 3.3: Temel SQL Injection Denemesi - ' OR '1'='1'
-- ---------------------------------------------
-- Bu deneme, WHERE koşulunu her zaman DOĞRU yapacak bir SQL ifadesi enjekte ederek
-- tüm kayıtları döndürmeyi amaçlar. '--' sonrası yorum satırı anlamına gelir
-- ve sorgunun geri kalanını etkisiz hale getirir.

DECLARE @searchName_injection1 NVARCHAR(255);
SET @searchName_injection1 = ''' OR ''1''=''1'' --';

DECLARE @sql_injection1 NVARCHAR(MAX);
SET @sql_injection1 = 'SELECT * FROM Airbnb_Cleaned_Final WHERE name LIKE ''%' + @searchName_injection1 + '%''';
EXEC (@sql_injection1);
GO

-- Bu sorguyu çalıştırdığınızda, normalde sadece 'Luxury' içeren kayıtlar yerine
-- veritabanındaki TÜM kayıtları görmelisiniz. Bu, SQL Injection zafiyetinin
-- başarılı bir şekilde nasıl kullanılabileceğini gösterir. Saldırgan,
-- uygulamanın sorgusuna kendi zararlı SQL kodunu ekleyerek veritabanının
-- tüm içeriğine erişebilir.

-- ---------------------------------------------
-- 3.4: Temel SQL Injection Denemesi - Yorum Satırı Kullanımı
-- ---------------------------------------------
-- Bu deneme, arama teriminden sonra bir yorum satırı ekleyerek sorgunun
-- orijinal WHERE koşulunun etkisiz hale getirilmesini amaçlar.

DECLARE @searchName_injection2 NVARCHAR(255);
SET @searchName_injection2 = 'Luxury'' --';

DECLARE @sql_injection2 NVARCHAR(MAX);
SET @sql_injection2 = 'SELECT * FROM Airbnb_Cleaned_Final WHERE name LIKE ''%' + @searchName_injection2 + '%''';
EXEC (@sql_injection2);
GO

-- Bu sorguyu çalıştırdığınızda, 'name' sütununda 'Luxury' ile biten
-- tüm kayıtları görmelisiniz. Saldırgan, orijinal sorgunun mantığını
-- değiştirerek farklı sonuçlar elde edebilir.

-- ---------------------------------------------
-- 3.5: Güvenli Arama Sorgusu (Parametreli)
-- ---------------------------------------------
-- Aşağıdaki örnek, aynı arama işlemini parametreli sorgu (prepared statement)
-- kullanarak güvenli bir şekilde nasıl gerçekleştirebileceğimizi göstermektedir.
-- Parametreli sorgularda, kullanıcı girdisi doğrudan SQL koduyla birleştirilmez,
-- bu da SQL Injection riskini ortadan kaldırır.

DECLARE @searchName_secure NVARCHAR(255);
SET @searchName_secure = ''' OR ''1''=''1'' --'; -- Zararlı giriş

-- Parametreli sorgu çalıştırma
EXEC sp_executesql N'SELECT * FROM Airbnb_Cleaned_Final WHERE name LIKE ''%'' + @isim + ''%''',
                   N'@isim NVARCHAR(255)',
                   @isim = @searchName_secure;
GO

-- Bu sorguyu çalıştırdığınızda, zararlı giriş (' OR '1'='1' --) normal bir
-- metin değeri olarak ele alınır ve büyük olasılıkla hiçbir kayıt dönmez
-- (çünkü tam olarak bu ifadeyi içeren bir oda adı olmayacaktır). Bu,
-- parametreli sorguların SQL Injection saldırılarına karşı ne kadar etkili
-- olduğunu gösterir.

-- ---------------------------------------------
-- 3.6: Güvenli Arama Sorgusu (Normal Girişle)
-- ---------------------------------------------
-- Parametreli sorgunun normal bir arama terimiyle nasıl çalıştığına bakalım.

DECLARE @searchName_secure_normal NVARCHAR(255);
SET @searchName_secure_normal = 'Luxury';

EXEC sp_executesql N'SELECT * FROM Airbnb_Cleaned_Final WHERE name LIKE ''%'' + @isim + ''%''',
                   N'@isim NVARCHAR(255)',
                   @isim = @searchName_secure_normal;
GO

-- Bu sorguyu çalıştırdığınızda, normalde beklendiği gibi 'Luxury' içeren
-- oda kayıtlarını görmelisiniz.
