-- Eventos

--    • ReporteVentasMensual: Genera un informe mensual de ventas y lo almacena automáticamente.

CREATE TABLE ReporteVentasMensual (
    IdReporte INT AUTO_INCREMENT PRIMARY KEY,
    Mes VARCHAR(7), -- formato YYYY-MM
    TotalVentas DECIMAL(10,2),
    FechaGeneracion DATETIME DEFAULT CURRENT_TIMESTAMP
);

DELIMITER $$

CREATE EVENT IF NOT EXISTS GenerarReporteVentasMensual
ON SCHEDULE EVERY 1 MONTH
STARTS '2025-09-01 00:00:00'
DO
BEGIN
    INSERT INTO ReporteVentasMensual (Mes, TotalVentas)
    SELECT 
        DATE_FORMAT(InvoiceDate, '%Y-%m') AS Mes,
        SUM(Total) AS TotalVentas
    FROM Invoice
    WHERE YEAR(InvoiceDate) = YEAR(CURRENT_DATE - INTERVAL 1 MONTH)
      AND MONTH(InvoiceDate) = MONTH(CURRENT_DATE - INTERVAL 1 MONTH)
    GROUP BY YEAR(InvoiceDate), MONTH(InvoiceDate);
END$$

DELIMITER ;


--    • ActualizarSaldosCliente: Actualiza los saldos de cuenta de clientes al final de cada mes.

CREATE TABLE IF NOT EXISTS SaldosClientes (
    CustomerId INT,
    Anio INT,
    Mes INT,
    Saldo DECIMAL(10,2),
    PRIMARY KEY (CustomerId, Anio, Mes)
);

DELIMITER $$

CREATE EVENT IF NOT EXISTS ActualizarSaldosCliente
ON SCHEDULE EVERY 1 MONTH
STARTS '2025-08-31 23:59:59'
DO
BEGIN
    INSERT INTO SaldosClientes (CustomerId, Anio, Mes, Saldo)
    SELECT 
        c.CustomerId,
        YEAR(CURRENT_DATE - INTERVAL 1 MONTH) AS Anio,
        MONTH(CURRENT_DATE - INTERVAL 1 MONTH) AS Mes,
        IFNULL(SUM(i.Total), 0) AS Saldo
    FROM Customer c
    LEFT JOIN Invoice i
        ON c.CustomerId = i.CustomerId
        AND YEAR(i.InvoiceDate) = YEAR(CURRENT_DATE - INTERVAL 1 MONTH)
        AND MONTH(i.InvoiceDate) = MONTH(CURRENT_DATE - INTERVAL 1 MONTH)
    GROUP BY c.CustomerId;
END$$

DELIMITER ;


--    • AlertaAlbumNoVendidoAnual: Envía una alerta cuando un álbum no ha registrado ventas en el último año.

CREATE TABLE IF NOT EXISTS AlbumAlerts (
    AlertId INT AUTO_INCREMENT PRIMARY KEY,
    AlbumId INT,
    AlertMessage VARCHAR(255),
    AlertDate DATETIME DEFAULT CURRENT_TIMESTAMP
);

DELIMITER $$

CREATE EVENT IF NOT EXISTS AlertaAlbumNoVendidoAnual
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
    INSERT INTO AlbumAlerts (AlbumId, AlertMessage)
    SELECT a.AlbumId, CONCAT('El álbum "', a.Title, '" no ha registrado ventas en el último año')
    FROM Album a
    LEFT JOIN Track t ON a.AlbumId = t.AlbumId
    LEFT JOIN InvoiceLine il ON t.TrackId = il.TrackId
    LEFT JOIN Invoice i ON il.InvoiceId = i.InvoiceId 
        AND i.InvoiceDate >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
    WHERE i.InvoiceId IS NULL;
END$$

DELIMITER ;


--    • LimpiarAuditoriaCada6Meses: Borra los registros antiguos de auditoría cada seis meses.

DELIMITER $$

CREATE EVENT LimpiarAuditoriaCada6Meses
ON SCHEDULE EVERY 6 MONTH
DO
BEGIN
    DELETE FROM Auditoria
    WHERE FechaRegistro < DATE_SUB(NOW(), INTERVAL 6 MONTH);
END$$

DELIMITER ;
--    • ActualizarListaDeGenerosPopulares: Actualiza la lista de géneros más vendidos al final de cada mes.

CREATE TABLE GenerosPopulares (
    id INT AUTO_INCREMENT PRIMARY KEY,
    mes YEAR(4) NOT NULL,
    mes_numero TINYINT NOT NULL,
    genero_id INT NOT NULL,
    genero_nombre VARCHAR(120) NOT NULL,
    total_vendido DECIMAL(10,2) NOT NULL
);

DELIMITER $$
CREATE EVENT ActualizarListaDeGenerosPopulares
ON SCHEDULE EVERY 1 MONTH
STARTS '2025-08-31 23:59:59'
DO
BEGIN
    -- Limpiar datos del mes actual si ya existían
    DELETE FROM GenerosPopulares
    WHERE mes = YEAR(CURDATE()) AND mes_numero = MONTH(CURDATE());

    -- Insertar los géneros más vendidos del mes actual
    INSERT INTO GenerosPopulares (mes, mes_numero, genero_id, genero_nombre, total_vendido)
    SELECT 
        YEAR(CURDATE()) AS anio,
        MONTH(CURDATE()) AS mes_numero,
        g.GenreId,
        g.Name AS genero_nombre,
        SUM(il.UnitPrice * il.Quantity) AS total_vendido
    FROM InvoiceLine il
    INNER JOIN Track t ON il.TrackId = t.TrackId
    INNER JOIN Genre g ON t.GenreId = g.GenreId
    INNER JOIN Invoice i ON il.InvoiceId = i.InvoiceId
    WHERE YEAR(i.InvoiceDate) = YEAR(CURDATE())
      AND MONTH(i.InvoiceDate) = MONTH(CURDATE())
    GROUP BY g.GenreId, g.Name
    ORDER BY total_vendido DESC;
END;

DELIMITER ;
