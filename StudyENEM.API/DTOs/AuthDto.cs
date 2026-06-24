namespace StudyENEM.API.DTOs;

public record LoginDto(string Identifier, string Password);

public record RegisterDto(string Name, string Email, string Password);

public record AuthUserDto(int Id, string Name, string Email);
