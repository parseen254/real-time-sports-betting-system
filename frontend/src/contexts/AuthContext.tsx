import React, { ReactNode, createContext, useEffect, useState } from 'react';

import axios from 'axios';

interface User {
  id: number;
  name: string;
  email: string;
  token: string;
}

interface AuthContextType {
  user: User | null;
  login: (email: string, password: string) => Promise<void>;
  signup: (name: string, email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
}

export const AuthContext = createContext<AuthContextType>({
  user: null,
  login: async () => {},
  signup: async () => {},
  logout: async () => {},
});

export const AuthProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);

  // On mount, load user data from localStorage if available
  useEffect(() => {
    const storedUser = localStorage.getItem('user');
    if (storedUser) setUser(JSON.parse(storedUser));
  }, []);

  const login = async (email: string, password: string) => {
    const response = await axios.post('http://localhost:3000/auth/login', { email, password });
    // Response structure: { user: { id, name, email }, token: '...' }
    const { user: userData, token } = response.data;
    const fullUser = { ...userData, token };
    setUser(fullUser);
    localStorage.setItem('user', JSON.stringify(fullUser));
  };

  const signup = async (name: string, email: string, password: string) => {
    const response = await axios.post('http://localhost:3000/users', { name, email, password });
    // Response structure: { user: { id, name, email }, token: '...' }
    const { user: userData, token } = response.data;
    const fullUser = { ...userData, token };
    // Optionally log the user in automatically after signup
    setUser(fullUser);
    localStorage.setItem('user', JSON.stringify(fullUser));
  };

  const logout = async () => {
    if (user) {
      await axios.post(
        'http://127.0.0.1:3000/auth/logout',
        {},
        {
          headers: {
            Authorization: `Bearer ${user.token}`,
          },
        }
      );
    }
    setUser(null);
    localStorage.removeItem('user');
  };

  return (
    <AuthContext.Provider value={{ user, login, signup, logout }}>
      {children}
    </AuthContext.Provider>
  );
};
