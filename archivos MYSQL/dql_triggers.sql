-- Triggers

--    • ActualizarTotalVentasEmpleado: Al realizar una venta, actualiza el total de ventas acumuladas por el empleado correspondiente.

CREATE TABLE VentasEmpleado (
    EmployeeId INT PRIMARY KEY,
    TotalVentas DECIMAL(10,2) DEFAULT 0
);


DELIMITER $$

CREATE TRIGGER ActualizarTotalVentasEmpleado
AFTER INSERT ON InvoiceLine
FOR EACH ROW
BEGIN
    DECLARE v_EmployeeId INT;

    -- Obtener el empleado que atendió la venta
    SELECT e.EmployeeId
    INTO v_EmployeeId
    FROM Invoice i
    JOIN Customer c ON i.CustomerId = c.CustomerId
    JOIN Employee e ON c.SupportRepId = e.EmployeeId
    WHERE i.InvoiceId = NEW.InvoiceId;

    -- Insertar o actualizar el total de ventas
    INSERT INTO VentasEmpleado (EmployeeId, TotalVentas)
    VALUES (v_EmployeeId, NEW.UnitPrice * NEW.Quantity)
    ON DUPLICATE KEY UPDATE
        TotalVentas = TotalVentas + (NEW.UnitPrice * NEW.Quantity);
END$$

DELIMITER ;


SELECT * FROM VentasEmpleado;


INSERT INTO Invoice (InvoiceId, CustomerId, InvoiceDate, BillingAddress, BillingCity, BillingState, BillingCountry, BillingPostalCode, Total)
VALUES (50000, 1, '2025-08-14', 'Fake Street 123', 'Bogotá', 'Cundinamarca', 'Colombia', '110111', 0);

INSERT INTO InvoiceLine (InvoiceLineId, InvoiceId, TrackId, UnitPrice, Quantity)
VALUES (50000, 50000, 1, 5.00, 2);


SELECT * FROM VentasEmpleado;


--    • AuditarActualizacionCliente: Cada vez que se modifica un cliente, registra el cambio en una tabla de auditoría.

CREATE TABLE AuditoriaCliente (
    AuditoriaId INT AUTO_INCREMENT PRIMARY KEY,
    CustomerId INT,
    OldFirstName VARCHAR(40),
    OldLastName VARCHAR(40),
    OldCompany VARCHAR(80),
    OldAddress VARCHAR(70),
    OldCity VARCHAR(40),
    OldState VARCHAR(40),
    OldCountry VARCHAR(40),
    OldPostalCode VARCHAR(10),
    OldPhone VARCHAR(24),
    OldFax VARCHAR(24),
    OldEmail VARCHAR(60),
    FechaCambio DATETIME,
    UsuarioQueModifico VARCHAR(100)
);

DELIMITER //

CREATE TRIGGER AuditarActualizacionCliente
AFTER UPDATE ON Customer
FOR EACH ROW
BEGIN
    INSERT INTO AuditoriaCliente (
        CustomerId, OldFirstName, OldLastName, OldCompany, OldAddress, OldCity,
        OldState, OldCountry, OldPostalCode, OldPhone, OldFax, OldEmail, 
        FechaCambio, UsuarioQueModifico
    )
    VALUES (
        OLD.CustomerId, OLD.FirstName, OLD.LastName, OLD.Company, OLD.Address, OLD.City,
        OLD.State, OLD.Country, OLD.PostalCode, OLD.Phone, OLD.Fax, OLD.Email,
        NOW(), USER()
    );
END;
//

DELIMITER ;

UPDATE Customer
SET FirstName = 'Carlos', LastName = 'Ramírez'
WHERE CustomerId = 1;

SELECT * FROM AuditoriaCliente;


--    • RegistrarHistorialPrecioCancion: Guarda el historial de cambios en el precio de las canciones.


CREATE TABLE HistorialPrecioCancion (
    HistorialId INT AUTO_INCREMENT PRIMARY KEY,
    TrackId INT NOT NULL,
    PrecioAnterior DECIMAL(10,2),
    PrecioNuevo DECIMAL(10,2),
    FechaCambio DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (TrackId) REFERENCES Track(TrackId)
);


DELIMITER $$
CREATE TRIGGER RegistrarHistorialPrecioCancion
BEFORE UPDATE ON Track
FOR EACH ROW
BEGIN
    IF OLD.UnitPrice <> NEW.UnitPrice THEN
        INSERT INTO HistorialPrecioCancion (TrackId, PrecioAnterior, PrecioNuevo)
        VALUES (OLD.TrackId, OLD.UnitPrice, NEW.UnitPrice);
    END IF;
END$$
DELIMITER ;

SELECT TrackId, Name, UnitPrice FROM Track LIMIT 5;

UPDATE Track
SET UnitPrice = UnitPrice + 1.00
WHERE TrackId = 1;

SELECT * FROM HistorialPrecioCancion;


--    • NotificarCancelacionVenta: Registra una notificación cuando se elimina un registro de venta.


CREATE TABLE NotificacionCancelacion (
    id INT AUTO_INCREMENT PRIMARY KEY,
    invoiceId INT,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    mensaje VARCHAR(255)
);


DELIMITER //
CREATE TRIGGER NotificarCancelacionVenta
AFTER DELETE ON Invoice
FOR EACH ROW
BEGIN
    INSERT INTO NotificacionCancelacion (invoiceId, mensaje)
    VALUES (
        OLD.InvoiceId,
        CONCAT('La venta con ID ', OLD.InvoiceId, ' fue cancelada el ', NOW())
    );
END;
//
DELIMITER ;

SELECT * FROM Invoice LIMIT 5;

DELETE FROM Invoice WHERE InvoiceId = 20;

SELECT * FROM NotificacionCancelacion;

--    • RestringirCompraConSaldoDeudor: Evita que un cliente con saldo deudor realice nuevas compras.

DELIMITER $$

CREATE TRIGGER RestringirCompraConSaldoDeudor
BEFORE INSERT ON Invoice
FOR EACH ROW
BEGIN
    DECLARE deuda DECIMAL(10,2);

    SELECT SUM(Total)
    INTO deuda
    FROM Invoice
    WHERE CustomerId = NEW.CustomerId
      AND Total > 0; 

    IF deuda IS NOT NULL AND deuda > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No se puede realizar la compra: cliente con saldo deudor';
    END IF;
END$$

DELIMITER ;

INSERT INTO Invoice (CustomerId, InvoiceDate, BillingAddress, BillingCity, BillingState, BillingCountry, BillingPostalCode, Total)
VALUES (1, NOW(), 'Calle Falsa 123', 'Ciudad X', 'Estado X', 'País X', '0000', 100.00);
