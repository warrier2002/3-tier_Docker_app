import { useEffect, useState } from 'react'
import { getItems, createItem, updateItem, deleteItem } from './api.js'
import './styles.css'

export default function App() {
  const [items, setItems] = useState([])
  const [name, setName] = useState('')
  const [description, setDescription] = useState('')
  const [editingId, setEditingId] = useState(null)
  const [error, setError] = useState('')

  async function load() {
    try {
      setItems(await getItems())
      setError('')
    } catch (e) {
      setError(e.message)
    }
  }

  useEffect(() => {
    load()
  }, [])

  async function handleSubmit(e) {
    e.preventDefault()
    if (!name.trim()) return
    try {
      if (editingId) {
        await updateItem(editingId, name, description)
        setEditingId(null)
      } else {
        await createItem(name, description)
      }
      setName('')
      setDescription('')
      await load()
      setError('')
    } catch (e) {
      setError(e.message)
    }
  }

  function startEdit(item) {
    setEditingId(item.id)
    setName(item.name)
    setDescription(item.description || '')
  }

  async function handleDelete(id) {
    try {
      await deleteItem(id)
      await load()
      setError('')
    } catch (e) {
      setError(e.message)
    }
  }

  return (
    <>
      <div className="bg-blobs" aria-hidden="true">
        <span />
        <span />
        <span />
      </div>

      <div className="app">
        <header className="glass hero">
          <h1>3-Tier Docker App</h1>
          <p>A containerized demo: Frontend → Backend → Database</p>
          <div className="tier-flow">
            <span className="tier-chip">React · Frontend</span>
            <span className="tier-chip">→</span>
            <span className="tier-chip">Flask · Backend</span>
            <span className="tier-chip">→</span>
            <span className="tier-chip">PostgreSQL · Database</span>
          </div>
        </header>

        <section className="glass panel">
          {error && <div className="error">{error}</div>}

          <form className="form" onSubmit={handleSubmit}>
            <input
              className="input"
              placeholder="Item name"
              value={name}
              onChange={(e) => setName(e.target.value)}
            />
            <input
              className="input"
              placeholder="Description (optional)"
              value={description}
              onChange={(e) => setDescription(e.target.value)}
            />
            <button type="submit" className="btn btn-primary">
              {editingId ? 'Update' : 'Add'} Item
            </button>
            {editingId && (
              <button
                type="button"
                className="btn btn-ghost"
                onClick={() => {
                  setEditingId(null)
                  setName('')
                  setDescription('')
                }}
              >
                Cancel
              </button>
            )}
          </form>

          <p className="count">
            {items.length} {items.length === 1 ? 'item' : 'items'}
          </p>

          {items.length === 0 ? (
            <p className="empty">No items yet — add your first one above.</p>
          ) : (
            <ul className="list">
              {items.map((it) => (
                <li className="item" key={it.id}>
                  <div className="item-main">
                    <div className="item-name">{it.name}</div>
                    {it.description && (
                      <div className="item-desc">{it.description}</div>
                    )}
                  </div>
                  <div className="item-actions">
                    <button className="btn btn-ghost btn-sm" onClick={() => startEdit(it)}>
                      Edit
                    </button>
                    <button className="btn btn-ghost btn-sm" onClick={() => handleDelete(it.id)}>
                      Delete
                    </button>
                  </div>
                </li>
              ))}
            </ul>
          )}
        </section>
      </div>
    </>
  )
}
