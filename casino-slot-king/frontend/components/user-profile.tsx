"use client"

import { useState, useEffect } from "react"
import { useAuth } from "@/context/auth-context"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { DataManager } from "@/components/data-manager"
import { AdminDashboard } from "@/components/admin-dashboard"
import type { GameSession } from "@/types"

export function UserProfile() {
  const { user, logout } = useAuth()
  const [gameHistory, setGameHistory] = useState<GameSession[]>([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState("")

  useEffect(() => {
    if (user) {
      fetchGameHistory()
    }
  }, [user])

  const fetchGameHistory = async () => {
    if (!user) return

    try {
      setLoading(true)
      const response = await fetch(`/api/user/${user.id}/history`)

      if (!response.ok) {
        throw new Error("Failed to fetch game history")
      }

      const data = await response.json()
      setGameHistory(data)
    } catch (error) {
      console.error("Error fetching game history:", error)
      setError("Failed to load game history")
    } finally {
      setLoading(false)
    }
  }

  if (!user) {
    return null
  }

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat("en-US", {
      style: "currency",
      currency: "USD",
      minimumFractionDigits: 0,
      maximumFractionDigits: 0,
    }).format(amount)
  }

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString()
  }

  // Show admin dashboard for admin users
  if (user.isAdmin) {
    return (
      <div className="space-y-4">
        <AdminDashboard />

        <Card>
          <CardHeader>
            <CardTitle>Admin Profile</CardTitle>
            <CardDescription>Welcome, {user.username}</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              <div className="flex justify-between items-center">
                <span className="font-medium">Admin Balance:</span>
                <span className="text-xl font-bold">{formatCurrency(user.balance)}</span>
              </div>

              <Button variant="outline" onClick={logout} className="w-full">
                Logout
              </Button>
            </div>
          </CardContent>
        </Card>

        <DataManager />
      </div>
    )
  }

  return (
    <div className="space-y-4">
      <Card>
        <CardHeader>
          <CardTitle>Your Profile</CardTitle>
          <CardDescription>Welcome back, {user.username}</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            <div className="flex justify-between items-center">
              <span className="font-medium">Current Balance:</span>
              <span className="text-xl font-bold">{formatCurrency(user.balance)}</span>
            </div>

            <div className="border-t pt-4">
              <h3 className="font-semibold mb-2">Recent Game History</h3>
              {loading ? (
                <div className="text-center py-2">Loading history...</div>
              ) : error ? (
                <div className="text-red-500">{error}</div>
              ) : gameHistory.length === 0 ? (
                <div className="text-center py-2">No game history yet</div>
              ) : (
                <div className="space-y-2">
                  {gameHistory.slice(0, 5).map((session) => (
                    <div key={session.id} className="border-b pb-2">
                      <div className="flex justify-between">
                        <span>{formatDate(session.startTime)}</span>
                        <span>
                          {session.finalBalance !== undefined
                            ? `${formatCurrency(session.finalBalance - session.initialBalance)}`
                            : "In progress"}
                        </span>
                      </div>
                      <div className="text-sm text-gray-500">{session.spins.length} spins</div>
                    </div>
                  ))}
                </div>
              )}
            </div>

            <Button variant="outline" onClick={logout} className="w-full">
              Logout
            </Button>
          </div>
        </CardContent>
      </Card>

      <DataManager />
    </div>
  )
}

