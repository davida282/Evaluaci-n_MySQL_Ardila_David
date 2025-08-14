-- Funciones

 --   • TotalGastoCliente(ClienteID, Anio): Calcula el gasto total de un cliente en un año específico.
    
DELIMITER $$

CREATE FUNCTION TotalGastoCliente(p_ClienteID INT, p_Anio INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_Total DECIMAL(10,2);

    SELECT IFNULL(SUM(Total), 0)
    INTO v_Total
    FROM Invoice
    WHERE CustomerId = p_ClienteID
      AND YEAR(InvoiceDate) = p_Anio;

    RETURN v_Total;
END$$

DELIMITER ;

SELECT TotalGastoCliente(1, 2022) AS Gasto_Cliente;

    
--    • PromedioPrecioPorAlbum(AlbumID): Retorna el precio promedio de las canciones de un álbum.

DELIMITER $$

CREATE FUNCTION PromedioPrecioPorAlbum(p_AlbumID INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE promedio DECIMAL(10,2);

    SELECT AVG(UnitPrice)
    INTO promedio
    FROM Track
    WHERE AlbumId = p_AlbumID;

    RETURN promedio;
END$$

DELIMITER ;

SELECT PromedioPrecioPorAlbum(1);


--    • DuracionTotalPorGenero(GeneroID): Calcula la duración total de todas las canciones vendidas de un género específico.

DELIMITER //

CREATE FUNCTION DuracionTotalPorGenero(p_GeneroID INT)
RETURNS BIGINT
DETERMINISTIC
BEGIN
    DECLARE total_ms BIGINT;

    SELECT SUM(t.Milliseconds * il.Quantity)
    INTO total_ms
    FROM InvoiceLine il
    INNER JOIN Track t ON il.TrackId = t.TrackId
    WHERE t.GenreId = p_GeneroID;

    RETURN IFNULL(total_ms, 0);
END //

DELIMITER ;

SELECT DuracionTotalPorGenero(1) AS Duracion_Milisegundos;


--    • DescuentoPorFrecuencia(ClienteID): Calcula el descuento a aplicar basado en la frecuencia de compra del cliente.

DELIMITER $$

CREATE FUNCTION DescuentoPorFrecuencia(clienteID INT)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE totalCompras INT;
    DECLARE descuento DECIMAL(5,2);

  
    SELECT COUNT(*) INTO totalCompras
    FROM Invoice
    WHERE CustomerId = clienteID;


    IF totalCompras <= 5 THEN
        SET descuento = 5.00;
    ELSEIF totalCompras <= 10 THEN
        SET descuento = 10.00;
    ELSE
        SET descuento = 15.00;
    END IF;

    RETURN descuento;
END$$

DELIMITER ;

SELECT DescuentoPorFrecuencia(1) AS Descuento;


--    • VerificarClienteVIP(ClienteID): Verifica si un cliente es "VIP" basándose en sus gastos anuales.

DELIMITER //

CREATE FUNCTION VerificarClienteVIP(p_CustomerId INT)
RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN
    DECLARE gasto_anual DECIMAL(10,2);


    SELECT SUM(Total)
    INTO gasto_anual
    FROM Invoice
    WHERE CustomerId = p_CustomerId
      AND YEAR(InvoiceDate) = YEAR(CURDATE());


    IF gasto_anual IS NULL THEN
        SET gasto_anual = 0;
    END IF;


    IF gasto_anual >= 1000 THEN
        RETURN 'VIP';
    ELSE
        RETURN 'Regular';
    END IF;
END;
//

DELIMITER ;

SELECT VerificarClienteVIP(5);

